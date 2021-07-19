#!/bin/bash

function linkf {
  if [[ -e "$1" ]]; then
    return
  fi
  ln -s "$2" "$1"
}

linkf "$HOME/.gitconfig" "$PWD/linux.gitconfig"
linkf "$HOME/.vimrc" "$PWD/.vimrc"
linkf "$HOME/.gvimrc" "$PWD/.gvimrc"
linkf "$HOME/.zshrc" "$PWD/.zshrc"
linkf "$HOME/.tmux.conf" "$PWD/.tmux.conf"
linkf "$HOME/shared" "$PWD/shared"

mkdir -p $HOME/.vim/colors 2>/dev/null

mkdir -p $HOME/.config/nvim 2>/dev/null
linkf "$HOME/.config/nvim/init.vim" "$PWD/init.vim"
