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
if (-not test-path $home\Documents\WindowsPowerShell) {
  mkdir $home\Documents\WindowsPowerShell
}
link $profile $pwd\profile.ps1
link $home\bin $pwd\bin

$userenv = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($userenv -inotcontains "$Home\bin") {
  [System.Environment]::SetEnvironmentVariable("Path", "$Home\bin;$userenv", "User")
}

#.\install-apps.ps1

. $PROFILE
