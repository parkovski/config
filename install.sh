#!/bin/bash

function setup {
  if [[ -e "$1" ]]; then
    return
  fi
  if [[ "$2" == "" ]]; then
    echo "mkdir $1"
    mkdir -p "$1"
  else
    echo "link $2 -> $1"
    ln -s "$2" "$1"
  fi
}

setup $HOME/.gitconfig $PWD/linux.gitconfig
setup $HOME/.zshrc $PWD/.zshrc
setup $HOME/.tmux.conf $PWD/.tmux.conf

setup $HOME/.local/bin
setup $HOME/.local/etc
setup $HOME/.share $PWD/share

setup $HOME/.vimrc $PWD/.vimrc
setup $HOME/.gvimrc $PWD/.gvimrc
# setup $HOME/.vim/colors

setup $HOME/.config/nvim
setup $HOME/.config/nvim/init.vim $PWD/init.vim

setup $HOME/.config/alacritty
setup $HOME/.config/alacritty/alacritty.yml $PWD/alacritty.yml

setup $HOME/.config/kitty
setup $HOME/.config/kitty.conf $PWD/kitty.conf

# setup $HOME/.config/environment.d
# setup $HOME/.config/environment.d/00-shared.conf $PWD/env.conf

if [[ "$EDITOR" == "" ]]; then
  echo "export EDITOR=nvim" >> $HOME/.zshenv
fi
if [[ "$VISUAL" == "" ]]; then
  echo "export VISUAL=nvim" >> $HOME/.zshenv
fi

if ! [[ -e $HOME/.zshenv ]]; then
  (
    <<-'EOF'
    export EDITOR=nvim
    export VISUAL=nvim
    # export PROMPT_GIT=1
    export PATH="$HOME/.local/bin:$HOME/.share/bin:$PATH"
    export GH=$HOME/Documents/dev
    export CMAKE_GENERATOR=Ninja
    export CMAKE_TOOLCHAIN_FILE=$HOME/.share/lib/toolchain.cmake
    EOF
  ) > $HOME/.zshenv
fi
