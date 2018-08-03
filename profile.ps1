$ProVar = @{}

$GH = "$HOME\Documents\GitHub"

. $HOME/bin/Get-OS.ps1
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

  $Target = $(Resolve-Path $Target).Path
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

function Enter-NewDirectory {
  param([Parameter(Mandatory=$true, Position=0)][string]$Path, [switch]$Push)
  if (-not (Test-Path $Path -PathType Container)) {
    New-Item $Path -ItemType Directory
  }
  if ($Push) {
    Push-Location $Path
  } else {
    Set-Location $Path
  }
}
Set-Alias mkcd Enter-NewDirectory

function Enter-ParentDirectory {
  param([int]$Levels = 1)
  Set-Location ("../" * $Levels)
}
Set-Alias up Enter-ParentDirectory

if (-not (Get-Command Set-Clipboard -ErrorAction Ignore)) {
  function Set-Clipboard {
    param(
      [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
      [string]$Text
    )

    $Text += [char]0
    $Text | clip.exe
  }
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
        Write-Host "Repo name is invalid."
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

  $c = 92
  if ($ProVar.admin) {
    $c = 91
  }
  Write-Host -NoNewLine "`e[${c}m$([System.Environment]::UserName)"
  Write-Host -NoNewLine "`e[90m@"
  Write-Host -NoNewLine "`e[${c}m$($ProVar.hostname) `e[m"

  # Git
  if ($isgit) {
    Write-Host -NoNewLine "`e[33m$branch"
    if ($ahead -gt 0) {
      Write-Host -NoNewLine "`e[90m: `e[34m+$ahead"
      if ($behind -gt 0) {
        Write-Host -NoNewLine "`e[90m/`e[35m-$behind"
      }
    } elseif ($behind -gt 0) {
      Write-Host -NoNewLine "`e[90m: `e[35m-$behind"
    }

    $colors = @{
      "+" = "`e[38;5;35m"; # Green
      "-" = "`e[38;5;160m"; # Red
      "?" = "`e[38;5;202m"; # Orange
    }
    if ($gitfiles.keys.Count -ne 0) {
      Write-Host -NoNewLine "`e[90m:"
      foreach ($k in $gitfiles.keys) {
        Write-Host -NoNewLine (" " + $colors["" + $k[1]] + $k[0] + $gitfiles[$k])
      }
    }
    Write-Host -NoNewLine "`e[90m: "
  }

  if ($components[0] -match ':$') {
    Write-Host -NoNewLine "`e[34m$($components[0])"
    $components[0] = ""
  }
  if ($components.Length -gt 1 -and $components[-1] -eq "") {
    $components = $components[0..($components.Length - 2)]
  }
  for ($i = 0; $i -lt $components.Length - 1; $i++) {
    Write-Host -NoNewLine (
      "`e[94m" +
      $components[$i][0] +
      ([System.IO.Path]::DirectorySeparatorChar)
    )
  }
  Write-Host -NoNewLine "`e[94m$($components[-1])"

  $global:LastExitCode = $exitCode
  [string]$ec = ""
  if ($exitCode -ne 0) {
    $ec = "[`e[31m$exitCode`e[90m] "
  }
  "`n`e[90m${ec}pwsh$('>' * ($NestedPromptLevel + 1))`e[m "
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
      Set-Location $HOME
    } else {
      Set-Location @args
    }
  }
}

$ProVar.PromptShowGitRemote = $true

try {
  Set-PSReadlineOption `
    -EditMode vi `
    -BellStyle None `
    -ViModeIndicator Script `
    -ViModeChangeHandler {
      if ($args[0] -eq 'Command') {
        Write-Host -NoNewLine "`e[1 q"
      } else {
        Write-Host -NoNewLine "`e[5 q"
      }
    } `
    -Colors @{
      Comment = "DarkGray";
      Keyword = "Cyan";
      String = "Yellow";
      Operator = "DarkYellow";
      Variable = "Magenta";
      Command = "DarkBlue";
      Parameter = "DarkGreen";
      Type = "DarkCyan";
      Number = "Green";
      Member = "Blue";
      Error = "DarkRed"
    }

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

} catch {
  Write-Host "Error setting PSReadLine options."
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['In-File:Encoding'] = 'utf8'

function Invoke-HistoryRecent {
  [CmdletBinding()]
  param()
  dynamicparam {
    $hist = Get-History
    $hc = $hist.Count

    # Fixme
    if ($hc -ge 10) {
      $hist = $hist[0..10]
    }
    # $values = [Enumerable]::Count(1, 10)
    $hint = "History count: $hc"
    for ($i = -1; $i -gt -$hist.Count; $i -= 1) {
      $hint += "`n" + $hist[$i].CommandLine
    }
    $hint = $values | Select-Object { "${_}: " + $hist[-$_] + "\n" }
    New-DynamicParams | Add-DynamicParam Index -Type:([int]) `
      -Position:0 -HelpMessage:$hint -Values:$values
  }
  process {
    $hist = Get-History
    $hc = $hist.Count

    $i = $PSBoundParameters.Index
    if ($i -ge 0 -and $i -lt $hc) {
      Invoke-History -Id:($hc-$i)
    }
  }
}

Set-Alias ^ Invoke-HistoryRecent

Import-Module Get-ChildItemColor
Set-Alias ls Get-ChildItemColorFormatWide
Set-Alias ll Get-ChildItemColor
Remove-Alias -Force sl -ErrorAction Ignore
function dirs { Get-Location -Stack }
function touch { echo '' >> $args[0] }
