$isadmin = `
  (New-Object Security.Principal.WindowsPrincipal `
    ([Security.Principal.WindowsIdentity]::GetCurrent())). `
  IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

function install {
  param([string]$link, [string]$target)

  if (test-path $link) {
    return
  }
  if ([string]::IsNullOrWhiteSpace($target)) {
    Write-Output "make $target"
    mkdir $target -ErrorAction Ignore
  } else {
    Write-Output "link $target --> $link"
    New-Item -Path $target -ItemType SymbolicLink -Value $link
  }
}

install $home\.gitconfig $pwd\windows.gitconfig

install $home\.local\bin
install $home\.local\etc
install $home\.share $pwd\share

install $home\_vimrc $pwd\.vimrc
install $home\.vimrc $pwd\.vimrc
install $home\_gvimrc $pwd\.gvimrc
install $home\.gvimrc $pwd\.gvimrc
install $home\.vim\colors
install $home\vimfiles $home\.vim

install $home\AppData\Local\nvim
install $home\AppData\Local\nvim\init.vim $pwd\init.vim

install $home\Documents\WindowsPowerShell
install $home\Documents\WindowsPowerShell\profile.ps1 $pwd\profile.ps1

install $home\Documents\PowerShell
install $home\Documents\PowerShell\profile.ps1 $pwd\profile.ps1

$userenv = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($userenv -inotcontains "$Home\.share\bin") {
  [System.Environment]::SetEnvironmentVariable("Path", "$Home\.share\bin;$userenv", "User")
}

if ($userenv -inotcontains "$Home\.local\bin") {
  [System.Environment]::SetEnvironmentVariable("Path", "$Home\.local\bin;$userenv", "User")
}

if (-not (test-path Env:\VCPKG_DEFAULT_TRIPLET)) {
  [System.Environment]::SetEnvironmentVariable('VCPKG_DEFAULT_TRIPLET', 'x64-windows', 'User')
}

[System.Environment]::SetEnvironmentVariable('EDITOR', 'nvim.exe', 'User')
[System.Environment]::SetEnvironmentVariable('VISUAL', 'nvim.exe', 'User')

if (!$isadmin) {
  Write-Output "Run this from an admin shell for further setup"
  return
}

&"$PSScriptRoot\.share\scripts\Windows\Enable-LongPaths.ps1"
&"$PSScriptRoot\.share\scripts\Windows\verbose-boot.ps1" -v $true

if (test-path HKLM:\SOFTWARE\WOW6432Node\WinFsp) {
  Set-ItemProperty HKLM:\SOFTWARE\WOW6432Node\WinFsp DistinctPermsForSameOwnerGroup -Type DWord -Value 1
}
if (test-path HKLM:\SOFTWARE\OpenSSH) {
  Set-ItemProperty HKLM:\SOFTWARE\OpenSSH DefaultShell 'C:\Program Files\PowerShell\7\pwsh.exe'
}
