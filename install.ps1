function link {
  param([string]$link, [string]$target)

  if (test-path $link) {
    return
  }

  if (test-path -pathtype container $target) {
    cmd /c mklink /d $link $target
  } else {
    cmd /c mklink $link $target
  }
}

link $home\.gitconfig $pwd\.gitconfig
link $home\_gvimrc $pwd\.gvimrc
link $home\.gvimrc $pwd\.gvimrc
link $home\_vimrc $pwd\.vimrc
link $home\.vimrc $pwd\.vimrc
link $home\config.xlaunch $pwd\config.xlaunch

mkdir $home\.vim -ea ignore
link $home\vimfiles $home\.vim
link $home\.vim\settings.json $pwd\vim-settings-windows.json

mkdir $home\AppData\Local\nvim -ea ignore
link $home\AppData\Local\nvim\init.vim $pwd\init.vim

mkdir $home\Documents\WindowsPowerShell -ea ignore
link $home\Documents\WindowsPowerShell\profile.ps1 $pwd\profile.ps1

mkdir $home\Documents\PowerShell -ea ignore
link $home\Documents\PowerShell\profile.ps1 $pwd\profile.ps1

link $home\shared $pwd\shared

$userenv = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($userenv -inotcontains "$Home\shared\bin") {
  [System.Environment]::SetEnvironmentVariable("Path", "$Home\shared\bin;$userenv", "User")
}

if ($userenv -inotcontains "$Home\local\bin") {
  [System.Environment]::SetEnvironmentVariable("Path", "$Home\local\bin;$userenv", "User")
}

if (-not (test-path Env:\VCPKG_DEFAULT_TRIPLET)) {
  [System.Environment]::SetEnvironmentVariable('VCPKG_DEFAULT_TRIPLET', 'x64-windows', 'User')
}

#.\install-apps.ps1

. "$pwd\profile.ps1"
