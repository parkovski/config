echo "if you are not admin, this will not end well."
if ((read-host -prompt "are you admin? y/n") -ne "y") {
  exit
}
$hasGit = read-host -prompt "is git installed and in $env:PATH? y/n"
if ($hasGit -ne "y") {
  exit
}

copy gitconfig $home\.gitconfig
copy gvimrc $home\_gvimrc
copy vimrc $home\_vimrc
mkdir $home\.vim\colors -erroraction ignore
cmd /c mklink /d %USERPROFILE%\vimfiles %USERPROFILE%\.vim
copy github.vim $home\.vim\colors
mkdir $home\Documents\WindowsPowerShell -erroraction ignore
copy profile.ps1 $PROFILE

. $PROFILE

mkdir $home\.vim\autoload -erroraction ignore
mkdir $home\.vim\bundle -erroraction ignore
download https://tpo.pe/pathogen.vim $home\.vim\autoload\pathogen.vim

.\gitcommands.sh.ps1
