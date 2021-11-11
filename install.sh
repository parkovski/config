#!/bin/bash

function setup {
  if [[ -e "$1" ]]; then
    return
  fi
  if [[ "$2" == "" ]]; then
    echo "make $1"
    mkdir -p "$1"
  else
    echo "link $2 --> $1"
    ln -s "$2" "$1"
  fi
}

setup $HOME/.gitconfig $PWD/linux.gitconfig
setup $HOME/.zshrc $PWD/.zshrc
setup $HOME/.tmux.conf $PWD/.tmux.conf

setup $HOME/local/bin
setup $HOME/local/etc
setup $HOME/shared $PWD/shared

setup $HOME/.vimrc $PWD/.vimrc
setup $HOME/.gvimrc $PWD/.gvimrc
setup $HOME/.vim/colors

setup $HOME/.config/nvim
setup $HOME/.config/nvim/init.vim $PWD/init.vim

if [[ -e $HOME/.zshenv ]]; then
  . ~/.zshenv
else
  touch $HOME/.zshenv
fi

if [[ "$EDITOR" == "" ]]; then
  echo "export EDITOR=nvim" >> $HOME/.zshenv
fi
if [[ "$VISUAL" == "" ]]; then
  echo "export VISUAL=nvim" >> $HOME/.zshenv
fi
