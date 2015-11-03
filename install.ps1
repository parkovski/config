echo "if you are not admin, this will not end well."
if ((read-host -prompt "are you admin? y/n") -ne "y") {
  exit
}
$hasGit = read-host -prompt "is git installed and in $env:PATH? y/n"
if ($hasGit -ne "y") {
  exit
}

copy gitconfig ~\.gitconfig
copy gvimrc ~\_gvimrc
copy vimrc ~\_vimrc
mkdir ~\.vim\colors -erroraction ignore
cmd /c mklink /d %USERPROFILE%\vimfiles %USERPROFILE%\.vim
copy github.vim ~\.vim\colors
mkdir ~\Documents\WindowsPowerShell -erroraction ignore
copy profile.ps1 $PROFILE

. $PROFILE

mkdir ~\.vim\autoload -erroraction ignore
mkdir ~\.vim\bundle -erroraction ignore
download https://tpo.pe/pathogen.vim ~\.vim\autoload\pathogen.vim

.\gitcommands.sh.ps1
