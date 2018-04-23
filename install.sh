#!/usr/bin/env zsh

function linkf {
  if [ -e "$HOME/$1" ]; then
    return
  fi
  ln -s "$PWD/$1" "$HOME/$1"
}

linkf .gitconfig
linkf .vimrc
linkf .gvimrc
linkf .zshrc
linkf .tmux.conf
linkf bin

