$ProVar = @{}

$GH = "$HOME\Documents\GitHub"
$env:GH = $GH

. $HOME/shared/lib/Get-OS.ps1
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
  if ($OS -eq "Windows") {
    function Set-Clipboard {
      param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string]$Text
      )

      $Text += [char]0
      $Text | clip.exe
    }
  }
}

. $HOME\shared\lib\dynparams.ps1
. $HOME\shared\lib\with.ps1

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
  Write-Escape -NoNewLine "``e[94m$($components[-1])"

  [string]$ec = ""
  if ($exitCode -eq -1) {
    # PowerShell gives this generic code on an exception
    $ec = "false"
  } elseif ($exitCode -lt -1 -or $exitCode -gt 255) {
    $ec = "0x" + [System.Convert]::ToString($exitCode, 16).ToUpper() + " ``e[36m($exitCode)"
  } elseif ($exitCode -ne 0) {
    $ec = "$exitCode"
  }
  if (-not ([string]::IsNullOrEmpty($ec))) {
    $ec = "[``e[31m$ec``e[90m] "
  }
  $prompt = _escify("`n``e[90m${ec}pwsh$('>' * ($NestedPromptLevel + 1))``e[m``e[5 q ")
  $global:LastExitCode = $exitCode
  $prompt
}

$env:EDITOR='vim'
$env:VISUAL='vim'
& {
  if (Test-Path "$HOME\shared\lib\paths.txt") {
    $fpaths = (gc "$HOME\shared\lib\paths.txt") -split "`n"
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

# Try to be flexible across PSReadline versions
function SetPSRLOption {
  $arg0 = $args[0]
  $arg1 = $args[1]

  try {
    $opts = @{ "$arg0" = $arg1 }
    Set-PSReadlineOption @opts
  } catch {
    Write-Escape "``e[91mError setting PSReadline option '``e[m$arg0``e[31m'.``e[m"
  }
}

function SetPSRLKey {
  try {
    Set-PSReadlineKeyHandler @args
  } catch {
    Write-Escape (
      "``e[91mError setting PSReadline key handler " +
      "'``e[m$args``e[31m'.``e[m"
    )
  }
}

SetPSRLOption BellStyle None
SetPSRLOption EditMode vi 
SetPSRLOption ViModeIndicator Cursor
SetPSRLOption ViModeIndicator Script
SetPSRLOption ViModeChangeHandler {
  if ($args[0] -eq 'Command') {
    Write-Escape -NoNewLine '`e[1 q'
  } else {
    Write-Escape -NoNewLine '`e[5 q'
  }
}
SetPSRLOption Colors @{
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
  error = "darkred"
}

SetPSRLKey -Key 'Shift+Tab' -Function Complete
SetPSRLKey -Key Tab -Function MenuComplete
SetPSRLKey -Key 'Ctrl+[' -Function ViCommandMode

SetPSRLKey -Key 'Ctrl+b' -ViMode Command -Function ScrollDisplayUp
SetPSRLKey -Key 'Ctrl+f' -ViMode Command -Function ScrollDisplayDown
SetPSRLKey -Key 'Ctrl+y' -ViMode Command -Function ScrollDisplayUpLine
SetPSRLKey -Key 'Ctrl+e' -ViMode Command -Function ScrollDisplayDownLine
SetPSRLKey -Key 'Ctrl+b' -ViMode Insert -Function ScrollDisplayUp
SetPSRLKey -Key 'Ctrl+f' -ViMode Insert -Function ScrollDisplayDown
SetPSRLKey -Key 'Ctrl+y' -ViMode Insert -Function ScrollDisplayUpLine
SetPSRLKey -Key 'Ctrl+e' -ViMode Insert -Function ScrollDisplayDownLine

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['In-File:Encoding'] = 'utf8'

function Invoke-HistoryRecent {
  [CmdletBinding()]
  param()
  dynamicparam {
    $hist = Get-History
    $hc = $hist.Count

    # FIXME
    if ($hc -ge 10) {
      $hist = $hist[-10 .. -1]
    }
    #$values = [System.Linq.Enumerable]::Count(1, $hist.Count)
    $hint = [System.Text.StringBuilder]::new("History count: $hc")
    for ($i = 0; $i -lt $hist.Count; $i += 1) {
      $hint.Append("`n").
        Append($i + 1).
        Append(": ").
        Append($hist[$hc - $i - 1].CommandLine)
    }
    # hint = $values | Select-Object { "${_}: " + $hist[-$_] + "\n" }
    $p = New-DynamicParams `
      | Add-DynamicParam -Name:'Index' `
        -Type:([int]) -Position:0 `
        -helpmessage:'hi' #-HelpMessage:($hint.ToString()) -Values:$values
    return $p
  }
  begin {
    $i = $PSBoundParameters.Index
    if ($i -eq 0) { $i = 1 }
    elseif ($i -lt 0) { $i = -$i }
  }
  process {
    $hist = Get-History
    $hc = $hist.Count

    Invoke-History -Id:($hc-$i)
  }
}

Set-Alias ^ Invoke-HistoryRecent

try {
  Import-Module Get-ChildItemColor
  Remove-Item -Force -ea Ignore Alias:\ls
  Remove-Item -Force -ea Ignore Alias:\sl
  Set-Alias ls Get-ChildItemColorFormatWide
  Set-Alias ll Get-ChildItemColor
} catch {
}

function dirs { Get-Location -Stack }
function touch { echo '' >> $args[0] }
