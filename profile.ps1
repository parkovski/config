$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['In-File:Encoding'] = 'utf8'

# Profile config.
$ProVar = @{
  ghuser = 'parkovski'
}

. $HOME/shared/lib/fsutils.ps1
Set-Alias mkcd Enter-NewDirectory
Set-Alias up Enter-ParentDirectory
Set-Alias in Invoke-InDirectory

. $HOME/shared/lib/Get-OS.ps1

. $HOME\shared\lib\dynparams.ps1

. $HOME\shared\lib\with.ps1
Set-Alias with Invoke-WithEnvironment
Set-Alias senv Set-EnvironmentVariable

. $HOME/shared/lib/history.ps1
Set-Alias ^ Invoke-HistoryRecent

$GH = "$HOME\Documents\GitHub"
$env:GH = $GH
# Note: $DDev is a secondary project dir.
. $HOME/shared/lib/gh.ps1

# Find if we're Admin/root.
if ($OS -eq "Windows") {
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  $ProVar.admin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  # This has the right capitalization
  $ProVar.hostname = (Get-CimInstance -ClassName Win32_ComputerSystem).DNSHostName
} else {
  $ProVar.admin = $(id -u) -eq "0"
  $ProVar.hostname = hostname
}

# Load OS-specific configuration.
if (Test-Path "$GH/config/Profile.$OS_BASE.ps1") {
  . "$GH/config/Profile.$OS_BASE.ps1"
}
if (($OS -ne $OS_BASE) -and (Test-Path "$GH/config/Profile.$OS.ps1")) {
  . "$GH/config/Profile.$OS.ps1"
}

# Fix missing Set-Clipboard.
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

$ProVar.PromptOpts = @{
  Git = $true;
  GitRemote = $true;
}
. $HOME/shared/lib/prompt.ps1

$env:EDITOR='vim'
$env:VISUAL='vim'

$PowerShell = (Get-Process -Id $PID).MainModule.FileName

# Add ~/shared/lib/paths.txt to $PATH.
& {
  $fpaths = $null
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

# Fix cd on old PowerShell.
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
  error = "darkred";
  continuationprompt = "darkgray"
}
# SetPSRLOption PromptText _escify('`e[90mpwsh> ')
SetPSRLOption ContinuationPrompt '[...]>> '

SetPSRLKey -Key 'Shift+Tab' -Function Complete
SetPSRLKey -Key Tab -Function MenuComplete
SetPSRLKey -Key 'Ctrl+d' -Function ViExit

SetPSRLKey -Key 'Ctrl+b' -ViMode Command -Function ScrollDisplayUp
SetPSRLKey -Key 'Ctrl+f' -ViMode Command -Function ScrollDisplayDown
SetPSRLKey -Key 'Ctrl+y' -ViMode Command -Function ScrollDisplayUpLine
SetPSRLKey -Key 'Ctrl+e' -ViMode Command -Function ScrollDisplayDownLine
SetPSRLKey -Key 'Ctrl+b' -ViMode Insert -Function ScrollDisplayUp
SetPSRLKey -Key 'Ctrl+f' -ViMode Insert -Function ScrollDisplayDown
SetPSRLKey -Key 'Ctrl+y' -ViMode Insert -Function ScrollDisplayUpLine
SetPSRLKey -Key 'Ctrl+e' -ViMode Insert -Function ScrollDisplayDownLine
SetPSRLKey -Key 'Ctrl+[' -ViMode Insert -Function ViCommandMode

# SetPSRLKey -Key 'Ctrl+]' -Function CopyScreen
# SetPSRLKey -Key 'Alt+h' -ViMode Insert -Function Left
# SetPSRLKey -Key 'Alt+l' -ViMode Insert -Function Right
# SetPSRLKey -Key 'Alt+w' -ViMode Insert -Function NextWord
# SetPSRLKey -Key 'Alt+b' -ViMode Insert -Function PreviousWord
# SetPSRLKey -Key 'z,z' -ViMode Command -Function ScrollToMiddle
# SetPSRLKey -Key 'z,t' -ViMode Command -Function ScrollToTop

if (Import-Module Get-ChildItemColor -PassThru -ErrorAction Ignore) {
  Remove-Item -Force -ea Ignore Alias:\ls
  Remove-Item -Force -ea Ignore Alias:\sl
  Set-Alias ls Get-ChildItemColorFormatWide
  Set-Alias ll Get-ChildItemColor
}

function dirs { Get-Location -Stack }
function touch { echo '' >> $args[0] }
