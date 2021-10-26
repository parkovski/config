using namespace System
using namespace System.Collections.Generic

$time__ = [DateTime]::UtcNow

# Base config
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['In-File:Encoding'] = 'utf8'

if (-not ($env:VISUAL)) {
  $env:VISUAL='nvim'
}
if (-not ($env:EDITOR)) {
  $env:EDITOR=$env:VISUAL
}

$global:PowerShell = (Get-Process -Id $PID).MainModule.FileName

# Profile config.
$global:ProVar = @{
  ghuser = 'parkovski'
}

Set-Alias = Select-Object

. $HOME/shared/lib/pwsh/fsutils.ps1
Set-Alias mkcd Enter-NewDirectory
Set-Alias up Enter-ParentDirectory
Set-Alias swapd Enter-AlternateDirectory
Set-Alias in Invoke-InDirectory

. $HOME/shared/lib/pwsh/Get-OS.ps1
# Find if we're Admin/root.
if ($OS -eq "Windows") {
  $ProVar.user = [Security.Principal.WindowsIdentity]::GetCurrent();
  $ProVar.admin = `
    (New-Object Security.Principal.WindowsPrincipal $ProVar.user). `
      IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  # This has the right capitalization
  $ProVar.hostname = (Get-CimInstance -ClassName Win32_ComputerSystem).DNSHostName
} else {
  $ProVar.admin = $(id -u) -eq "0"
  $ProVar.hostname = hostname
}

. $HOME\shared\lib\pwsh\dynparams.ps1

. $HOME\shared\lib\pwsh\with.ps1
Set-Alias with Invoke-WithEnvironment
Set-Alias senv Set-EnvironmentVariable
Set-Alias genv Get-EnvironmentVariable

. $HOME/shared/lib/pwsh/history.ps1
Set-Alias ^ Invoke-HistoryRecent

function dirs { Get-Location -Stack }
function touch { New-Item -Path $args[0] -ItemType File }

if (![string]::IsNullOrEmpty($env:GH)) {
  $global:GH = $env:GH
  if (![string]::IsNullOrEmpty($env:GH2)) {
    $global:GH2 = $env:GH2
  }
  . $HOME/shared/lib/pwsh/gh.ps1
} else {
  function gh {
    Write-Error "`$env:GH is not defined"
  }
}

# Add ~/shared/lib/paths.txt to $PATH.
& {
  $fpaths = $null
  if (Test-Path "$HOME\shared\lib\paths.txt") {
    $fpaths = (Get-Content "$HOME\shared\lib\paths.txt") -split "`n"
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
if ($Host.Runspace.Version.Major -lt 6) {
  . "$HOME/shared/lib/pwsh/oldprofile.ps1"
  exit
}

# Load OS-specific configuration.
if (Test-Path "$GH/config/Profile.$OS_BASE.ps1") {
  . "$GH/config/Profile.$OS_BASE.ps1"
}
if (($OS -ne $OS_BASE) -and (Test-Path "$GH/config/Profile.$OS.ps1")) {
  . "$GH/config/Profile.$OS.ps1"
}

. $HOME/shared/lib/pwsh/prompt.ps1

Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -EditMode vi 
Set-PSReadlineOption -ViModeIndicator Cursor
Set-PSReadlineOption -ViModeIndicator Script -ErrorAction Ignore
Set-PSReadlineOption -ViModeChangeHandler {
  if ($args[0] -eq 'Command') {
    [System.Console]::Out.Write("`e[1 q")
  } else {
    [System.Console]::Out.Write("`e[5 q")
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

Set-PSReadlineOption -PromptText @("`e[33m> `e[5 q`e[0m", "`e[31m> `e[0m")
Set-PSReadlineOption -ContinuationPrompt "`e[33m-> `e[0m"

Set-PSReadlineKeyHandler -Key 'Shift+Tab' -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key 'Ctrl+d' -Function ViExit
Set-PSReadlineKeyHandler -Key 'Ctrl+k' -Function DeleteLine

Set-PSReadlineKeyHandler -Key 'Ctrl+b' -ViMode Command -Function ScrollDisplayUp
Set-PSReadlineKeyHandler -Key 'Ctrl+f' -ViMode Command -Function ScrollDisplayDown
Set-PSReadlineKeyHandler -Key 'Ctrl+y' -ViMode Command -Function ScrollDisplayUpLine
Set-PSReadlineKeyHandler -Key 'Ctrl+e' -ViMode Command -Function ScrollDisplayDownLine
Set-PSReadlineKeyHandler -Key 'Ctrl+b' -ViMode Insert -Function ScrollDisplayUp
Set-PSReadlineKeyHandler -Key 'Ctrl+f' -ViMode Insert -Function ScrollDisplayDown
Set-PSReadlineKeyHandler -Key 'Ctrl+y' -ViMode Insert -Function ScrollDisplayUpLine
Set-PSReadlineKeyHandler -Key 'Ctrl+e' -ViMode Insert -Function ScrollDisplayDownLine
Set-PSReadlineKeyHandler -Key 'Ctrl+[' -ViMode Insert -Function ViCommandMode
Set-PSReadlineKeyHandler -Key 'Ctrl+Oem4' -ViMode Insert -Function ViCommandMode

# Set-PSReadlineKeyHandler -Key 'Ctrl+]' -Function CopyScreen
# Set-PSReadlineKeyHandler -Key 'Alt+h' -ViMode Insert -Function Left
# Set-PSReadlineKeyHandler -Key 'Alt+l' -ViMode Insert -Function Right
# Set-PSReadlineKeyHandler -Key 'Alt+w' -ViMode Insert -Function NextWord
# Set-PSReadlineKeyHandler -Key 'Alt+b' -ViMode Insert -Function PreviousWord
# Set-PSReadlineKeyHandler -Key 'z,z' -ViMode Command -Function ScrollToMiddle
# Set-PSReadlineKeyHandler -Key 'z,t' -ViMode Command -Function ScrollToTop

if ($IsWindows) {
  Add-Type -TypeDefinition '
  public class JimmyJimmy {
    private const int STD_INPUT_HANDLE = -10;
    private const int STD_OUTPUT_HANDLE = -11;
    private const int STD_ERROR_HANDLE = -12;
    private const uint FILE_TYPE_CHAR = 2;
    [System.Runtime.InteropServices.DllImport("kernel32.dll")]
    private static extern System.IntPtr GetStdHandle(int handleId);
    [System.Runtime.InteropServices.DllImport("kernel32.dll")]
    private static extern uint GetFileType(System.IntPtr handle);
    public static bool IsTtyIn() {
      return GetFileType(GetStdHandle(STD_INPUT_HANDLE)) == FILE_TYPE_CHAR;
    }
    public static bool IsTtyOut() {
      return GetFileType(GetStdHandle(STD_OUTPUT_HANDLE)) == FILE_TYPE_CHAR;
    }
    public static bool IsTtyErr() {
      return GetFileType(GetStdHandle(STD_ERROR_HANDLE)) == FILE_TYPE_CHAR;
    }
  }
  '
} else {
  Add-Type -TypeDefinition '
  public class JimmyJimmy {
    private const int STDIN_FILENO = 0;
    private const int STDOUT_FILENO = 1;
    private const int STDERR_FILENO = 2;
    [System.Runtime.InteropServices.DllImport("libc")]
    private static extern int isatty(int fileno);
    public static bool IsTtyIn() {
      return isatty(STDIN_FILENO) == 1;
    }
    public static bool IsTtyOut() {
      return isatty(STDOUT_FILENO) == 1;
    }
    public static bool IsTtyErr() {
      return isatty(STDERR_FILENO) == 1;
    }
  }
  '
}

Remove-Alias -Force -ea Ignore ls
function ls {
  $thestuff = Get-ChildItem @args

  if (!$thestuff) {
    return
  }

  istty -o
  if ($LASTEXITCODE -ne 0) {
    return $thestuff
  }

  $thestuff = $thestuff | ForEach-Object {
    $name = $_.Name
    $islink = $_.LinkType -eq 'SymbolicLink'
    $isdir = ($_.Attributes -band [System.IO.FileAttributes]::Directory) -ne 0
    if ($_.Extension) {
      $isexe = (($env:PATHEXT + ';.PS1') -split ';') -contains $_.Extension.ToUpper()
    } else {
      $isexe = $false
    }

    if ($isdir) {
      $name = "`e[36m$name`e[m"
    } elseif ($isexe) {
      $name = "`e[38;5;208m$name`e[m"
    }

    if ($islink) {
      $name += "@"
    } elseif (($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
      $name += "?"
    } elseif ($isdir) {
      $name += [System.IO.Path]::DirectorySeparatorChar
    } elseif ($isexe) {
      $name += "*"
    }
    #[PSCustomObject]@{ Name = $name }
    New-Object PSObject -Property @{ Name = $name }
  } | Format-Wide -AutoSize -Property Name

  # Get rid of the extra new lines Format-Wide adds.
  @("`e[2F", $thestuff, "`e[2F")
}
Set-Alias ll Get-ChildItem

$time__ = [DateTime]::UtcNow - $time__
if ([JimmyJimmy]::IsTtyOut()) {
  Write-Output "`e[G`e[2KProfile loaded in `e[32m$($time__.Seconds).$($time__.Milliseconds)s`e[m."
}
Remove-Item Variable:\time__
