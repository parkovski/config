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

if (-not (test-path "$home\Documents\WindowsPowerShell")) {
  mkdir $home\Documents\WindowsPowerShell
}
link $home\Documents\WindowsPowerShell\profile.ps1 $pwd\profile.ps1

if (-not (test-path "$home\Documents\PowerShell")) {
  mkdir $home\Documents\PowerShell
}
link $home\Documents\PowerShell\profile.ps1 $pwd\profile.ps1

link $home\shared $pwd\shared

$userenv = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($userenv -inotcontains "$Home\shared\bin") {
  [System.Environment]::SetEnvironmentVariable("Path", "$Home\shared\bin;$userenv", "User")
}

if (-not (test-path Env:\VCPKG_DEFAULT_TRIPLET)) {
  [System.Environment]::SetEnvironmentVariable('VCPKG_DEFAULT_TRIPLET', 'x64-windows', 'User')
}

#.\install-apps.ps1

. "$pwd\profile.ps1"
