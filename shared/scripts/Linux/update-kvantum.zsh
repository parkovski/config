#!/bin/zsh
# Update Kvantum from themes installed by ocs-url.
cd $HOME/.themes
fd -e kvconfig | sed 's/^\([^/]\+\)\/.\+/\1/g' | read -Ar -d '' dirs
for d in $dirs; do
  if [[ ! -x "$HOME/.config/Kvantum/$d" ]]; then
    ln -s "$HOME/.themes/$d" "$HOME/.config/Kvantum/$d"
  fi
done