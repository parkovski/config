# Fix cd on old PowerShell.
if (test-path Alias:cd) {
  rm -force Alias:cd
}
function cd {
  if ($args.Length -eq 0) {
    Set-Location $HOME
  } else {
    Set-Location @args
  }
}

function prompt {
  if ($?) {
    $global:LastExitCode = 0
  } elseif ($global:LastExitCode -eq 0) {
    $global:LastExitCode = -1
  }
  [int]$exitCode = $global:LastExitCode

  $esc = [char]0x1b

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
  Write-Host -NoNewLine (
    "$esc[${c}m$([System.Environment]::UserName)" +
    "$esc[90m@" +
    "$esc[${c}m$($ProVar.hostname) $esc[m"
  )

  # Git
  if ($isgit) {
    Write-Host -NoNewLine "$esc[33m$branch"
    if ($ahead -gt 0) {
      Write-Host -NoNewLine "$esc[90m: $esc[34m+$ahead"
      if ($behind -gt 0) {
        Write-Host -NoNewLine "$esc[90m/$esc[35m-$behind"
      }
    } elseif ($behind -gt 0) {
      Write-Host -NoNewLine "$esc[90m: $esc[35m-$behind"
    }

    $colors = @{
      "+" = "$esc[38;5;35m"; # Green
      "-" = "$esc[38;5;160m"; # Red
      "?" = "$esc[38;5;202m"; # Orange
    }
    if ($gitfiles.keys.Count -ne 0) {
      Write-Host -NoNewLine "$esc[90m:"
      foreach ($k in $gitfiles.keys) {
        Write-Host -NoNewLine (" " + $colors["" + $k[1]] + $k[0] + $gitfiles[$k])
      }
    }
    Write-Host -NoNewLine "$esc[90m: "
  }

  if ($components[0] -match ':$') {
    Write-Host -NoNewLine "$esc[34m$($components[0])"
    $components[0] = ""
  }
  if ($components.Length -gt 1 -and $components[-1] -eq "") {
    $components = $components[0..($components.Length - 2)]
  }
  for ($i = 0; $i -lt $components.Length - 1; $i++) {
    Write-Host -NoNewLine (
      "$esc[94m" +
      $components[$i][0] +
      ([System.IO.Path]::DirectorySeparatorChar)
    )
  }
  Write-Host "$esc[94m$($components[-1])"

  [string]$ec = ""
  if ($exitCode -eq -1) {
    # PowerShell gives this generic code on an exception
    $ec = "-1"
  } elseif ($exitCode -eq 0xC000013A) {
    # NT status code for "exited by Ctrl-C"
    $ec = "^C"
  } elseif ($exitCode -lt -1 -or $exitCode -gt 255) {
    $ec = "0x" + [System.Convert]::ToString($exitCode, 16).ToUpper() + " $esc[36m($exitCode)"
  } elseif ($exitCode -ne 0) {
    $ec = "$exitCode"
  }
  if (-not ([string]::IsNullOrEmpty($ec))) {
    $ec = "[$esc[31m$ec$esc[90m] "
  }
  $prompt = "$esc[90m${ec}pwsh$('>' * ($NestedPromptLevel + 1))$esc[m"
  $global:LastExitCode = $exitCode
  $prompt
}

Set-PSReadlineOption -BellStyle None -EditMode vi -ViModeIndicator Cursor
Set-PSReadlineOption -Colors @{
  comment = "darkgray";
  keyword = "cyan";
  string = "yellow";
  operator = "darkyellow";
  variable = "magenta";
  command = "darkblue";
  parameter = "darkgreen";
  type = "darkcyan";
  number = "green";
  member = "blue";
  error = "darkred";
  continuationprompt = "darkgray"
} -ErrorAction Ignore

Set-PSReadlineKeyHandler -Key 'Shift+Tab' -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key 'Ctrl+d' -Function ViExit

Set-PSReadlineKeyHandler -Key 'Ctrl+b' -ViMode Command -Function ScrollDisplayUp
Set-PSReadlineKeyHandler -Key 'Ctrl+f' -ViMode Command -Function ScrollDisplayDown
Set-PSReadlineKeyHandler -Key 'Ctrl+y' -ViMode Command -Function ScrollDisplayUpLine
Set-PSReadlineKeyHandler -Key 'Ctrl+e' -ViMode Command -Function ScrollDisplayDownLine
Set-PSReadlineKeyHandler -Key 'Ctrl+b' -ViMode Insert -Function ScrollDisplayUp
Set-PSReadlineKeyHandler -Key 'Ctrl+f' -ViMode Insert -Function ScrollDisplayDown
Set-PSReadlineKeyHandler -Key 'Ctrl+y' -ViMode Insert -Function ScrollDisplayUpLine
Set-PSReadlineKeyHandler -Key 'Ctrl+e' -ViMode Insert -Function ScrollDisplayDownLine
Set-PSReadlineKeyHandler -Key 'Ctrl+[' -ViMode Insert -Function ViCommandMode
