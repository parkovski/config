$ProVar = @{}

$GH = "$HOME\Documents\GitHub"

. ~/bin/Get-OS.ps1
if ($OS -eq "Windows") {
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  $ProVar.admin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  # This has the right capitalization
  $ProVar.hostname = (Get-CimInstance -ClassName Win32_ComputerSystem).DNSHostName
} else {
  $ProVar.admin = $(id -u) -eq "0"
  $ProVar.hostname = hostname
}

$PowerShell = (Get-Process -Id $PID).MainModule.FileName
if (Test-Path "$GH/config/Profile.$OS_BASE.ps1") {
  . "$GH/config/Profile.$OS_BASE.ps1"
}
if (($OS -ne $OS_BASE) -and (Test-Path "$GH/config/Profile.$OS.ps1")) {
  . "$GH/config/Profile.$OS.ps1"
}

function New-SymLink {
  param([string]$Target, [string]$Link, [Alias('d')][switch]$Dir)

  if ($OS -eq "Windows") {
    if ((Test-Path $Target -PathType Container) -or $Dir) {
      cmd /c mklink /D $Link $Target
    } else {
      cmd /c mklink $Link $Target
    }
  } else {
    ln -s $Target $Link
  }
}

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

. $HOME\bin\lib\dynparams.ps1
. $HOME\bin\lib\with.ps1

function gh {
  [CmdletBinding()]
  param(
    [Alias('t')][switch]$ThirdParty,
    [Alias('n')][switch]$NewProject,
    [Alias('d')][switch]$DevExternal,
    [Alias('c')][switch]$Clone
  )
  dynamicparam {
    $Projects = $null
    if ((-not $NewProject) -and (-not $Clone)) {
      $Dir = $GH
      if ($DevExternal -and [bool]$DDev) {
        $Dir = $DDev
      } elseif ($ThirdParty) {
        $Dir = "$GH\3rd-party"
      }
      $Projects = $(Get-ChildItem $Dir | % Name)
    }
    $p = New-DynamicParams | `
      Add-DynamicParam Project -Type:([String]) -HelpMessage:"Project Name" `
        -Position:0 -NotNullOrEmpty:$NewProject -Values:$Projects
    if ($Clone) {
      $p | Add-DynamicParam LocalDir -Type:([String]) `
        -HelpMessage:"Local clone dir"  -Position:1
    }
    return $p
  }
  begin {
    if ($DevExternal) {
      if (-not $DDev) {
        Write-Output "External dev directory is not set up."
        return
      }
      $Dir = $DDev
    } elseif ($ThirdParty) {
      $Dir = "$GH\3rd-party"
    } else {
      $Dir = $GH
    }

    $Project = $PSBoundParameters.Project
    if ($Clone) {
      if ($Project.StartsWith('parkovski/')) {
        $Repo = "git@github.com:$Project"
      } else {
        $Repo = "https://github.com/$Project"
      }
      if (-not $LocalDir) {
        $LocalDir = $Project.Substring($Project.IndexOf('/') + 1)
      }
    }
  }
  process {
    if ($NewProject) {
      cd $Dir
      mkdir $Project
      cd $Project
      git init
    } elseif ($Clone) {
      if (-not ($Project -match "[a-zA-Z0-9\-_]+\/[a-zA-Z0-9\-_]+")) {
        echo "Repo name is invalid."
        return
      }
      cd $Dir
      git clone $Repo $LocalDir
      cd $LocalDir
    } else {
      cd "$Dir\$Project"
    }
  }
}

function prompt {
  $exitCode = $global:LastExitCode

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
  $ahead = 0
  $behind = 0
  if ($isgit) {
    $gitfiles = Get-GitStatusMap
    if ($ProVar.PromptShowGitRemote) {
      $remote = $(git rev-parse --abbrev-ref --symbolic-full-name '@{u}')
      if ($remote) {
        $ahead_str = git rev-list --count "$remote..HEAD"
        $_ = [int]::TryParse($ahead_str.Trim(), [ref]$ahead)
        $behind_str = git rev-list --count "HEAD..$remote"
        $_ = [int]::TryParse($behind_str.Trim(), [ref]$behind)
      }
    }
  }

  if ($ProVar.admin) {
    Write-Host ([System.Environment]::UserName) -ForegroundColor Red -NoNewLine
    Write-Host "@" -ForegroundColor DarkGray -NoNewLine
    Write-Host $ProVar.hostname -ForegroundColor Red -NoNewLine
  } else {
    Write-Host ([System.Environment]::UserName) -ForegroundColor Green -NoNewLine
    Write-Host "@" -ForegroundColor DarkGray -NoNewLine
    Write-Host $ProVar.hostname -ForegroundColor Green -NoNewLine
  }
  Write-Host " " -NoNewLine

  # Git
  if ($isgit) {
    $gitspace = ''
    Write-Host "$branch" -ForegroundColor DarkYellow -NoNewLine
    Write-Host "(" -ForegroundColor DarkGray -NoNewLine
    if ($ahead -gt 0) {
      Write-Host "+$ahead" -ForegroundColor DarkBlue -NoNewLine
      if ($behind -gt 0) {
        Write-Host "/" -ForegroundColor DarkGray -NoNewLine
      }
      $gitspace = ' '
    }
    if ($behind -gt 0) {
      Write-Host "-$behind" -ForegroundColor DarkMagenta -NoNewLine
      $gitspace = ' '
    }
    foreach ($k in $gitfiles.keys) {
      if ($k[1] -eq "+") {
        $c = "DarkGreen"
      } else {
        $c = "DarkRed"
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
    $components[0] = ""
    Write-Host '[' -ForegroundColor Gray -NoNewLine
    Write-Host $drv -ForegroundColor DarkBlue -NoNewLine
    Write-Host '] ' -ForegroundColor Gray -NoNewLine
  }
  for ($i = 0; $i -lt $components.Length - 1; $i++) {
    Write-Host $components[$i][0] -ForegroundColor Blue -NoNewLine
    Write-Host ([System.IO.Path]::DirectorySeparatorChar) -ForegroundColor Blue -NoNewLine
  }
  Write-Host "$($components[-1])" -ForegroundColor Blue -NoNewLine

  $esc = [char]27
  $global:LastExitCode = $exitCode
  "`n${esc}[90mpwsh$('>' * ($NestedPromptLevel + 1))${esc}[m "
}

$env:EDITOR='vim'
$env:VISUAL='vim'
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

$ProVar.PromptShowGitRemote = $true

try {
  Set-PSReadlineOption -EditMode vi
  Set-PSReadlineOption -BellStyle None
  #Set-PSReadlineOption -ViModeIndicator Cursor
  Set-PSReadlineOption -ViModeIndicator Escape
  Set-PSReadlineOption -ViCommandModeText "`e[1 q"
  Set-PSReadlineOption -ViInsertModeText "`e[5 q"
  Set-PSReadlineKeyHandler -Key 'Shift+Tab' -Function Complete
  Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
  Set-PSReadlineKeyHandler -Key 'Ctrl+[' -Function ViCommandMode

  Set-PSReadlineKeyHandler -Key 'Ctrl+b' -ViMode Command -Function ScrollDisplayUp
  Set-PSReadlineKeyHandler -Key 'Ctrl+f' -ViMode Command -Function ScrollDisplayDown
  Set-PSReadlineKeyHandler -Key 'Ctrl+y' -ViMode Command -Function ScrollDisplayUpLine
  Set-PSReadlineKeyHandler -Key 'Ctrl+e' -ViMode Command -Function ScrollDisplayDownLine
  Set-PSReadlineKeyHandler -Key 'Ctrl+b' -ViMode Insert -Function ScrollDisplayUp
  Set-PSReadlineKeyHandler -Key 'Ctrl+f' -ViMode Insert -Function ScrollDisplayDown
  Set-PSReadlineKeyHandler -Key 'Ctrl+y' -ViMode Insert -Function ScrollDisplayUpLine
  Set-PSReadlineKeyHandler -Key 'Ctrl+e' -ViMode Insert -Function ScrollDisplayDownLine

  Set-PSReadlineOption -Colors @{
    Comment = "DarkGray";
    Keyword = "DarkBlue";
    String = "Yellow";
    Operator = "DarkMagenta";
    Variable = "DarkYellow";
    Command = "DarkGreen";
    Parameter = "DarkCyan";
    Type = "Blue";
    Number = "Red";
    Member = "DarkMagenta";
    Error = "DarkRed"
  }
} catch {
  echo "Error setting PSReadLine options."
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['In-File:Encoding'] = 'utf8'

Set-Alias ^ Invoke-History
