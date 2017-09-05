echo "this needs admin. also Set-ExecutionPolicy Unrestricted now."
if ((read-host -prompt "are you admin? y/n") -ne "y") {
  exit
}

.\install-apps.ps1

copy .\.gitconfig $home\.gitconfig
copy .\.gvimrc $home\_gvimrc
copy .\.vimrc $home\_vimrc
expand-archive $home\OneDrive\Documents\Utils\vimfiles.zip -DestinationPath $home
mkdir $home\Documents\WindowsPowerShell
copy .\profile.ps1 $PROFILE

mkdir $home\bin
cp .\with.ps1,.\Remove-RustFmtBk.ps1 $home\bin

. $PROFILE
