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

function in {
  param($dir, $cmd)
  pushd $dir
  & $cmd $args[-2..-1]
  popd
}

$GH = "$HOME\Documents\GitHub"
function gh {
  [CmdletBinding()]
  param(
    [Alias('t')][switch]$ThirdParty=$false,
    [Alias('n')][switch]$NewProject=$false
  )
  dynamicparam {
    $d = "$HOME\Documents\GitHub"
    if ($ThirdParty) {
      $d += "\3rd-party"
    }
    if ($NewProject) {
      $projects = ""
    } else {
      $projects = $(Get-ChildItem $d | % Name)
    }
    return $(&"$HOME\bin\lib\mktabcomplete.ps1" -name "Project" -help "Project name" -values $projects -position 0)
  }
  begin {
    $Project = $PSBoundParameters.Project
    if ($ThirdParty) {
      $Project = "3rd-party\$Project"
    }
  }
  process {
    if ($NewProject) {
      mkdir "$GH\$Project"
      cd "$GH\$Project"
      git init
    } else {
      cd "$GH\$Project"
    }
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

  $branch = git symbolic-ref --short HEAD 2> $null
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
    Write-Host ([System.Environment]::UserName) -ForegroundColor Red -NoNewLine
    Write-Host "@" -ForegroundColor DarkGray -NoNewLine
    Write-Host $ProVar.hostname -ForegroundColor Red -NoNewLine
  } else {
    Write-Host ([System.Environment]::UserName) -ForegroundColor DarkGreen -NoNewLine
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

  if ($components[0] -eq "~" -or $components[0] -eq "") {
  } elseif ($components[0] -ieq $env:SystemDrive) {
    $components[0] = ""
  } elseif ($components[0] -match ':$') {
    $drv = $components[0].Substring(0, $components[0].Length - 1)
    #$components = $components[1..$components.Length]
    $components[0] = ""
    Write-Host '[' -ForegroundColor Gray -NoNewLine
    Write-Host $drv -ForegroundColor DarkBlue -NoNewLine
    Write-Host '] ' -ForegroundColor Gray -NoNewLine
  }
  for ($i = 0; $i -lt $components.Length - 1; $i++) {
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
if (Test-Path "$GH/config/Profile.${$ProVar.os}.ps1") {
  . "$GH/config/Profile.${$ProVar.os}.ps1"
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
