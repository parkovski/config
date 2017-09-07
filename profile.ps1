function download {
  param($from, $to)
  (curl $from).Content > $to
}

function escape_for_bash {
  param($str)
  $out = ""
  foreach ($c in $str.ToCharArray()) {
    if ($c -eq "\") {
      $out += "\\"
    } elseif ($c -eq "`"") {
      $out += "\`""
    } else {
      $out += $c
    }
  }
  return $out
}

function escape_for_zsh {
  param($str)
  $out = ""
  foreach ($c in $str.ToCharArray()) {
    if ($c -eq "\") {
      $out += "\\\\"
    } elseif ($c -eq "`"") {
      $out += "\\\`""
    } else {
      $out += $c
    }
  }
  return $out
}

function concat_args {
  $s = ""
  foreach ($arg in $args) {
    $s += $arg + " "
  }
  return $s
}

function c { cmd /c @args }
function b {
  $s = escape_for_bash(concat_args($args))
  echo $s
  bash -c "$s"
}
function z {
  $s = escape_for_zsh(concat_args($args))
  echo $s
  bash -c "zsh -c \`"$s\`""
}

function zsh {
  bash -c zsh
}

function in {
  param($dir, $cmd)
  pushd $dir
  & $cmd $args[-2..-1]
  popd
}

if (test-path Alias:cd) {
  rm -force Alias:cd
}
function cd {
  if ($args.Length -eq 0) {
    Set-Location ~
  } else {
    Set-Location @args
  }
}

$GH = "$home\Documents\GitHub"
function gh {
  [CmdletBinding()]
  param()
  dynamicparam {
    $projects = $(ls "$home\Documents\GitHub" | %{$_.name})
    return $(&"$HOME\bin\lib\mktabcomplete.ps1" -name "project" -mandatory -help "Project name" -values $projects)
  }
  begin {
    $project = $PSBoundParameters.project
  }
  process {
    cd "$home\Documents\GitHub\$project"
  }
}

function Get-GitStatusMap {
  $status = $(git status --porcelain=1)
  $map = @{}
  if ($status) {
    $status = $status.Split("`n")
  } else {
    return $map
  }

  foreach ($line in $status) {
    $k = ""
    if ($line[1] -ne " ") {
      $k = $line[1] + "-"
    } else {
      $k = $line[0] + "+"
    }
    $map[$k] = $map[$k] + 1
  }
  $map
}

function prompt {
  $exitCode = $LastExitCode
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  $admin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  $path = $ExecutionContext.SessionState.Path.CurrentLocation.Path
  $_ = $path -match "^([A-Za-z]+:)?([\\/])(?:(?:.+[\\/])?([^\\/]+)[\\/]?)?$"
  $drive = $matches[1]
  if (-not $drive) { $drive = $matches[2] }
  $isgit = Test-Path ".git" -PathType Container
  if ($isgit) {
    $branch = $(git branch --format "%(refname:short)")
    $gitfiles = Get-GitStatusMap
    if ($PromptShowGitRemote) {
      $remote = $(git remote show)
      $ahead = 0
      $behind = 0
      if ($remote) {
        $ahead_str = $(git rev-list --count $remote/HEAD..HEAD)
        $_ = [int]::TryParse($ahead_str, [ref]$ahead)
        $behind_str = $(git rev-list --count HEAD..$remote/HEAD)
        $_ = [int]::TryParse($behind_str, [ref]$behind)
      }
    }
  }

  if ($admin) {
    Write-Host "+A" -ForegroundColor Yellow -NoNewLine
  }
  Write-Host "[$drive]" -ForegroundColor Blue -NoNewLine
  if ($path -ieq $home) {
    $folder = " ~"
  } elseif ($matches[3]) {
    $folder = $matches[3]
  } else {
    $folder = $matches[2]
  }
  Write-Host " $folder" -ForegroundColor Cyan -NoNewLine
  if ($isgit) {
    Write-Host " git:(" -ForegroundColor Blue -NoNewLine
    Write-Host $branch -ForegroundColor DarkYellow -NoNewLine
    if ($PromptShowGitRemote) {
      if ($ahead -gt 0) {
        Write-Host "+$ahead" -ForegroundColor DarkBlue -NoNewLine
        if ($behind -gt 0) {
          Write-Host "/" -ForegroundColor DarkYellow -NoNewLine
        }
      }
      if ($behind -gt 0) {
        Write-Host "-$behind" -ForegroundColor DarkMagenta -NoNewLine
      }
    }
    foreach ($k in $gitfiles.keys) {
      if ($k[1] -eq "+") {
        $c = "Cyan"
      } else {
        $c = "Red"
      }
      Write-Host " $($k[0])$($gitfiles[$k])" -ForegroundColor $c -NoNewLine
    }
    Write-Host ")" -ForegroundColor Blue -NoNewLine
  }
  $LastExitCode = $exitCode
  " $('>' * ($NestedPromptLevel + 1)) "
}

$env:EDITOR='vim'
$env:PATH=$env:PATH+";$HOME\Downloads\OpenSSH-Win64"
function = {
  param(
    [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
    $in,
    [Parameter(Position=0, Mandatory=$true)]
    $filter
  )

  begin {
    $out = [System.Collections.Generic.List`1[object]]::new()
  }
  process {
    foreach ($value in $in) {
      $val = $in | Select-Object $filter
      if (($val -ne $null) -and ($val.$filter -ne $null)) {
        $val = $val.$filter
      }
      $out.Add($val)
    }
  }
  end {
    return $out
  }
}

$PromptShowGitRemote = $false

Set-PSReadlineOption -EditMode vi
Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Chord 'Shift+Tab' -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key Ctrl+[ -Function ViCommandMode

