$ProVar = @{}

function Download-TextFile {
  param([string]$From, [string]$To)
  if (Test-Path -PathType Container $To) {
    $slash = $From.LastIndexOf('/')
    if (-not ($To.EndsWith('/') -or $To.EndsWith('\'))) {
      $To += [System.IO.Path]::PathSeparator
    }
    $To += $From.Substring($slash + 1);
  }
  (Invoke-WebRequest $From -ContentType "text/plain").Content `
    | Out-File -Encoding "utf8" -NoNewLine $To
}

function linux_shell_escape {
  param($str)
  $out = ""
  foreach ($c in $str.ToCharArray()) {
    if ($c -eq "\") {
      $out += "\\"
    } elseif ($c -eq "`"") {
      $out += "\`""
    } elseif ($c -eq " ") {
      $out += "\ "
    } else {
      $out += $c
    }
  }
  return $out
}

function linux_shell_args {
  $args | ForEach-Object {
    if (Test-Path $_) {
      $_
    } else {
      linux_shell_escape $_
    }
  }
}

function c { cmd /c @args }
function b {
  $s = linux_shell_args @args
  ubuntu run bash -c @s
}
function z {
  $s = linux_shell_args @args
  ubuntu run zsh -c @s
}

Set-Alias zsh ubuntu.exe

function in {
  param($dir, $cmd)
  pushd $dir
  & $cmd $args[-2..-1]
  popd
}

$GH = "$home\Documents\GitHub"
function gh {
  [CmdletBinding()]
  param()
  dynamicparam {
    $projects = $(ls "$home\Documents\GitHub" | %{$_.name})
    return $(&"$HOME\bin\lib\mktabcomplete.ps1" -name "project" -help "Project name" -values $projects)
  }
  begin {
    $project = $PSBoundParameters.project
  }
  process {
    cd "$home\Documents\GitHub\$project"
  }
}

if ([System.Environment]::OSVersion.Platform -eq "Win32NT") {
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  $ProVar.os = 'Windows'
  $ProVar.admin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  # This has the right capitalization
  $ProVar.hostname = (Get-CimInstance -ClassName Win32_ComputerSystem).DNSHostName
} else {
  $ProVar.os = uname -s
  $ProVar.admin = $(id -u) -eq "0"
  $ProVar.hostname = hostname
}

function prompt {
  $exitCode = $LastExitCode

  function Get-GitStatusMap {
    $status = git status --porcelain=1
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

  $path = $ExecutionContext.SessionState.Path.CurrentLocation.Path
  if ($path.StartsWith($HOME)) {
    $path = '~' + $path.Substring($HOME.Length)
  }
  $components = $path -split [regex]'[/\\]'
  $path = ''
  for ($i = 0; $i -le $components.Length - 1; $i++) {
    $path += $components[$i][0] + [System.IO.Path]::DirectorySeparatorChar
  }
  $path += $components[-1]

  $branch = git symbolic-ref --short HEAD
  $isgit = $LASTEXITCODE -eq 0
  if ($isgit) {
    $gitfiles = Get-GitStatusMap
    if ($ProVar.PromptShowGitRemote) {
      $remote = $(git rev-parse --abbrev-ref --symbolic-full-name `@`{u`})
      $ahead = 0
      $behind = 0
      if ($remote) {
        $ahead_str = git rev-list --count $remote..HEAD
        $_ = [int]::TryParse($ahead_str, [ref]$ahead)
        $behind_str = git rev-list --count HEAD..$remote
        $_ = [int]::TryParse($behind_str, [ref]$behind)
      }
    }
  }

  if ($ProVar.admin) {
    Write-Host $env:USERNAME -ForegroundColor Red -NoNewLine
    Write-Host "@" -ForegroundColor DarkGray -NoNewLine
    Write-Host $ProVar.hostname -ForegroundColor Red -NoNewLine
  } else {
    Write-Host $env:USERNAME -ForegroundColor DarkGreen -NoNewLine
    Write-Host "@" -ForegroundColor DarkGray -NoNewLine
    Write-Host $ProVar.hostname -ForegroundColor DarkGreen -NoNewLine
  }
  Write-Host " " -NoNewLine

  # Git
  if ($isgit) {
    #Write-Host "git:(" -ForegroundColor Blue -NoNewLine
    $gitspace = ''
    Write-Host "$branch" -ForegroundColor DarkYellow -NoNewLine
    Write-Host "(" -ForegroundColor DarkGray -NoNewLine
    if ($ProVar.PromptShowGitRemote) {
      if ($ahead -gt 0) {
        Write-Host "+$ahead" -ForegroundColor DarkBlue -NoNewLine
        if ($behind -gt 0) {
          Write-Host "/" -ForegroundColor DarkYellow -NoNewLine
        }
        $gitspace = ' '
      }
      if ($behind -gt 0) {
        Write-Host "-$behind" -ForegroundColor DarkMagenta -NoNewLine
        $gitspace = ' '
      }
    }
    foreach ($k in $gitfiles.keys) {
      if ($k[1] -eq "+") {
        $c = "Green"
      } else {
        $c = "Red"
      }
      Write-Host "$gitspace$($k[0])$($gitfiles[$k])" -ForegroundColor $c -NoNewLine
      $gitspace = ' '
    }
    Write-Host ") " -ForegroundColor DarkGray -NoNewLine
  }

  for ($i = 0; $i -le $components.Length - 1; $i++) {
    Write-Host $components[$i][0] -ForegroundColor DarkBlue -NoNewLine
    Write-Host ([System.IO.Path]::DirectorySeparatorChar) -ForegroundColor DarkBlue -NoNewLine
  }
  Write-Host $components[-1] -ForegroundColor DarkBlue -NoNewLine

  $LastExitCode = $exitCode
  "$('>' * ($NestedPromptLevel + 1)) "
}

$env:EDITOR='vim'
& {
  if (Test-Path "$HOME\bin\lib\paths.txt") {
    $fpaths = (gc "$HOME\bin\lib\paths.txt") -split "`n"
    if ($env:PATH.IndexOf($fpaths[-1]) -ne -1) {
      return;
    }
  }
  if ($fpaths) {
    $sep = [System.IO.Path]::PathSeparator
    if (-not $env:PATH.EndsWith($sep)) {
      $env:PATH += $sep
    }
    $env:PATH += ($fpaths -join $sep)
  }
}

if (-not ($PSVersionTable.PSCompatibleVersions | % major).Contains(6)) {
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
}


$PowerShell = (Get-Process -Id $PID).MainModule.FileName
function Open-AdminWindow {
  Start-Process $PowerShell -Verb Runas
}

$ProVar.vcvars = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
function vcvars {
  param([bool]$Force = $false)

  if ($ProVar.vcvars_set -and -not $Force) {
    Write-Host "Aw dawg you savin like 3 to 4 seconds cuz its already set!"
    return;
  }
  cmd /c "`"$($ProVar.vcvars)`" & set" | ?{$_ -match "^[A-Za-z_0-9]+="} | %{
    $var = $_
    $eq = $var.IndexOf('=');
    $key = $var.Substring(0, $eq);
    $val = $var.Substring($eq + 1);
    sc "Env:\$key" "$val"
  }
  $ProVar.vcvars_set = $true
  Write-Host "Dawg, vcvars is r-r-r-ready to roll"
}

$ProVar.PromptShowGitRemote = $true

Set-PSReadlineOption -EditMode vi
Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -ViModeIndicator Cursor
Set-PSReadlineKeyHandler -Key 'Shift+Tab' -Function Complete
Set-PSReadlineKeyHandler -Key 'Alt+c' -Function Complete
Set-PSReadlineKeyHandler -Key 'Alt+q' -Function TabCompletePrevious
Set-PSReadlineKeyHandler -Key 'Alt+w' -Function TabCompleteNext
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key 'Ctrl+[' -Function ViCommandMode

Set-PSReadlineKeyHandler -Key 'Ctrl+B' -ViMode Command -Function ScrollDisplayUp
Set-PSReadlineKeyHandler -Key 'Ctrl+F' -ViMode Command -Function ScrollDisplayDown
Set-PSReadlineKeyHandler -Key 'Ctrl+Y' -ViMode Command -Function ScrollDisplayUpLine
Set-PSReadlineKeyHandler -Key 'Ctrl+E' -ViMode Command -Function ScrollDisplayDownLine
Set-PSReadlineKeyHandler -Key 'Ctrl+B' -ViMode Insert -Function ScrollDisplayUp
Set-PSReadlineKeyHandler -Key 'Ctrl+F' -ViMode Insert -Function ScrollDisplayDown
Set-PSReadlineKeyHandler -Key 'Ctrl+Y' -ViMode Insert -Function ScrollDisplayUpLine
Set-PSReadlineKeyHandler -Key 'Ctrl+E' -ViMode Insert -Function ScrollDisplayDownLine

try {
  Set-PSReadlineOption -TokenKind Comment   -Color DarkBlue
  Set-PSReadlineOption -TokenKind Keyword   -Color Green
  Set-PSReadlineOption -TokenKind String    -Color Magenta
  Set-PSReadlineOption -TokenKind Operator  -Color Red
  Set-PSReadlineOption -TokenKind Variable  -Color Yellow
  Set-PSReadlineOption -TokenKind Command   -Color Blue
  Set-PSReadlineOption -TokenKind Parameter -Color DarkCyan
  Set-PSReadlineOption -TokenKind Type      -Color DarkGreen
  Set-PSReadlineOption -TokenKind Number    -Color Magenta
  Set-PSReadlineOption -TokenKind Member    -Color Gray
  Set-PSReadlineOption -ErrorForegroundColor DarkRed
} catch {
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['In-File:Encoding'] = 'utf8'

. $HOME\bin\lib\rustup-completions.ps1
