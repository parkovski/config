# For compatibility with older powershell
function _escify {
  param([Parameter(ValueFromPipeline=$true, Position=0)][string]$s)
  return $s -Replace '`e', "$([char]27)"
}

function Write-Escape {
  param([switch]$NoNewLine=$false)
  $e = [string][char]27
  for ($i = 0; $i -lt $args.Length; $i += 1) {
    $args[$i] = $args[$i] -Replace '`e', $e
  }
  Write-Host -NoNewLine:$NoNewLine @args
}

function prompt {
  if ($?) {
    $global:LastExitCode = 0
  } elseif ($global:LastExitCode -eq 0) {
    $global:LastExitCode = -1
  }
  [int]$exitCode = $global:LastExitCode

  function Get-GitStatusMap {
    $status = git status --porcelain=1
    $map = @{}
    if ($status) {
      $status = $status.Split("`n")
    } else {
      return $map
    }

    foreach ($line in $status) {
      if ([string]::IsNullOrEmpty($line.Trim())) {
        continue
      }
      $k = "" + $line[0]
      if ($line[1] -eq "?") {
        $k = "??"
      } elseif ($line[1] -ne " ") {
        $k = $line[1] + "-"
      } else {
        $k = $line[0] + "+"
      }
      $map[$k] = $map[$k] + 1
    }
    $map
  }

  $path = $ExecutionContext.SessionState.Path.CurrentLocation.Path
  if ($path.StartsWith($HOME)) {
    $path = '~' + $path.Substring($HOME.Length)
  }
  $components = $path -split [regex]'[/\\]'

  $isgit = $false
  if ($ProVar.PromptOpts.Git) {
    $branch = git symbolic-ref --short HEAD 2> $null
    $isgit = $LASTEXITCODE -eq 0
    $ahead = 0
    $behind = 0
    if ($isgit) {
      $gitfiles = Get-GitStatusMap
      if ($ProVar.PromptOpts.GitRemote) {
        $remote = $(git rev-parse --abbrev-ref --symbolic-full-name '@{u}')
        if ($remote) {
          $ahead_str = git rev-list --count "$remote..HEAD"
          $_ = [int]::TryParse($ahead_str.Trim(), [ref]$ahead)
          $behind_str = git rev-list --count "HEAD..$remote"
          $_ = [int]::TryParse($behind_str.Trim(), [ref]$behind)
        }
      }
    }
  }

  $c = 92
  if ($ProVar.admin) {
    $c = 91
  }
  Write-Escape -NoNewLine "``e[${c}m$([System.Environment]::UserName)"
  Write-Escape -NoNewLine "``e[90m@"
  Write-Escape -NoNewLine "``e[${c}m$($ProVar.hostname) ``e[m"

  # Git
  if ($isgit) {
    Write-Escape -NoNewLine "``e[33m$branch"
    if ($ahead -gt 0) {
      Write-Escape -NoNewLine "``e[90m: ``e[34m+$ahead"
      if ($behind -gt 0) {
        Write-Escape -NoNewLine "``e[90m/``e[35m-$behind"
      }
    } elseif ($behind -gt 0) {
      Write-Escape -NoNewLine "``e[90m: ``e[35m-$behind"
    }

    $colors = @{
      "+" = _escify('`e[38;5;35m'); # Green
      "-" = _escify('`e[38;5;160m'); # Red
      "?" = _escify('`e[38;5;202m'); # Orange
    }
    if ($gitfiles.keys.Count -ne 0) {
      Write-Escape -NoNewLine '`e[90m:'
      foreach ($k in $gitfiles.keys) {
        Write-Host -NoNewLine (" " + $colors["" + $k[1]] + $k[0] + $gitfiles[$k])
      }
    }
    Write-Escape -NoNewLine '`e[90m: '
  }

  if ($components[0] -match ':$') {
    Write-Escape -NoNewLine "``e[34m$($components[0])"
    $components[0] = ""
  }
  if ($components.Length -gt 1 -and $components[-1] -eq "") {
    $components = $components[0..($components.Length - 2)]
  }
  for ($i = 0; $i -lt $components.Length - 1; $i++) {
    Write-Escape -NoNewLine (
      '`e[94m' +
      $components[$i][0] +
      ([System.IO.Path]::DirectorySeparatorChar)
    )
  }
  Write-Escape "``e[94m$($components[-1])"

  [string]$ec = ""
  if ($exitCode -eq -1) {
    # PowerShell gives this generic code on an exception
    $ec = "-1"
  } elseif ($exitCode -lt -1 -or $exitCode -gt 255) {
    $ec = "0x" + [System.Convert]::ToString($exitCode, 16).ToUpper() + " ``e[36m($exitCode)"
  } elseif ($exitCode -ne 0) {
    $ec = "$exitCode"
  }
  if (-not ([string]::IsNullOrEmpty($ec))) {
    $ec = "[``e[31m$ec``e[90m] "
  }
  $prompt = _escify("``e[90m${ec}pwsh$('>' * ($NestedPromptLevel + 1))``e[m``e[5 q ")
  $global:LastExitCode = $exitCode
  $prompt
}
