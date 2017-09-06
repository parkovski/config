echo "This needs admin. Also Set-ExecutionPolicy Bypass now."
if ((read-host -prompt "Continue? y/n") -ne "y") {
  exit
}

copy .\.gitconfig $home\.gitconfig
copy .\.gvimrc $home\_gvimrc
copy .\.vimrc $home\_vimrc
expand-archive $home\OneDrive\Documents\Utils\vimfiles.zip -DestinationPath $home
mkdir $home\Documents\WindowsPowerShell -ErrorAction Ignore
copy .\profile.ps1 $PROFILE

mkdir $home\bin -ErrorAction Ignore
cp .\bin\* $home\bin

.\install-apps.ps1

cp $HOME\OneDrive\Documents\Utils\ConEmu.xml $HOME\AppData\Roaming

. $PROFILE
