# Base config

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['In-File:Encoding'] = 'utf8'

# Stop it from adding backslashes to the title.
Write-Host -NoNewLine "$([char]0x1b)]2;pwsh $($Host.Version.ToString())$([char]0x1b)\"

if (-not ($env:VISUAL)) {
  $env:VISUAL='nvim'
}
if (-not ($env:EDITOR)) {
  $env:EDITOR=$env:VISUAL
}

$PowerShell = (Get-Process -Id $PID).MainModule.FileName

# Profile config.
$ProVar = @{
  ghuser = 'parkovski'
}

. $HOME/shared/lib/fsutils.ps1
Set-Alias mkcd Enter-NewDirectory
Set-Alias up Enter-ParentDirectory
Set-Alias in Invoke-InDirectory

. $HOME/shared/lib/Get-OS.ps1
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

. $HOME\shared\lib\dynparams.ps1

. $HOME\shared\lib\with.ps1
Set-Alias with Invoke-WithEnvironment
Set-Alias senv Set-EnvironmentVariable
Set-Alias genv Get-EnvironmentVariable

. $HOME/shared/lib/history.ps1
Set-Alias ^ Invoke-HistoryRecent

function dirs { Get-Location -Stack }
function touch { echo '' >> $args[0] }

$GH = "$HOME\Documents\GitHub"
$env:GH = $GH
# Note: $DDev is a secondary project dir.
. $HOME/shared/lib/gh.ps1

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

$ProVar.PromptOpts = @{
  Git = $true;
  GitRemote = $true;
}

# For compatibility with older powershell
if ($Host.Version.Major -lt 6) {
  . "$HOME/shared/lib/oldprofile.ps1"
  exit
}

# Load OS-specific configuration.
if (Test-Path "$GH/config/Profile.$OS_BASE.ps1") {
  . "$GH/config/Profile.$OS_BASE.ps1"
}
if (($OS -ne $OS_BASE) -and (Test-Path "$GH/config/Profile.$OS.ps1")) {
  . "$GH/config/Profile.$OS.ps1"
}

. $HOME/shared/lib/prompt.ps1

Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -EditMode vi 
Set-PSReadlineOption -ViModeIndicator Cursor
Set-PSReadlineOption -ViModeIndicator Script -ErrorAction Ignore
Set-PSReadlineOption -ViModeChangeHandler {
  if ($args[0] -eq 'Command') {
    Write-Host -NoNewLine "`e[1 q"
  } else {
    Write-Host -NoNewLine "`e[5 q"
  }
} -ErrorAction Ignore
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
}
# TODO: Find how to get the color back after an error correction.
Set-PSReadlineOption -PromptText '> '
Set-PSReadlineOption -ContinuationPrompt '... > '

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

# Set-PSReadlineKeyHandler -Key 'Ctrl+]' -Function CopyScreen
# Set-PSReadlineKeyHandler -Key 'Alt+h' -ViMode Insert -Function Left
# Set-PSReadlineKeyHandler -Key 'Alt+l' -ViMode Insert -Function Right
# Set-PSReadlineKeyHandler -Key 'Alt+w' -ViMode Insert -Function NextWord
# Set-PSReadlineKeyHandler -Key 'Alt+b' -ViMode Insert -Function PreviousWord
# Set-PSReadlineKeyHandler -Key 'z,z' -ViMode Command -Function ScrollToMiddle
# Set-PSReadlineKeyHandler -Key 'z,t' -ViMode Command -Function ScrollToTop

if (Import-Module Get-ChildItemColor -PassThru -ErrorAction Ignore) {
  Remove-Item -Force -ea Ignore Alias:\ls
  Remove-Item -Force -ea Ignore Alias:\sl
  Set-Alias ls Get-ChildItemColorFormatWide
  Set-Alias ll Get-ChildItemColor
}
