if [[ "$OS_BASE" == "Linux" ]]; then
  userdir=~/.config/Code/User
elif [[ "$OS_BASE" == "macOS" ]]; then
  userdir=~/Library/Application\ Support/Code/User 
else
  echo "Unknown OS $OS_BASE"
  exit 1
fi

if [[ "$1" == "--sync" ]]; then
  cp $userdir/*.json $GH/config/vscode
else
  cp $GH/config/vscode/* $userdir
fi
