CONFIG=$(pwd)
function linkf() {
  rm "~/$1" 2>/dev/null
  ln -s "$CONFIG/$1" "~/$1"
}

linkf .zshrc
linkf .gitconfig
linkf .vimrc
linkf .gvimrc
linkf .tmux.conf
if [[ -f ~/OneDrive/Documents/Utils/vimfiles.zip ]]; then
  unzip ~/OneDrive/Documents/Utils/vimfiles.zip -d ~
  mv ~/vimfiles ~/.vim
fi

