if [[ $(uname -r | grep Microsoft) ]]; then
  export DISPLAY=:0
  export LIBGL_ALWAYS_INDIRECT=1
  export WHOME=/mnt/c/Users/parker
  # export VIMTERM=tmux-256color
fi

if [[ -f ~/bin/etc/lscolors.txt ]]; then
  export LS_COLORS=$(cat ~/bin/etc/lscolors.txt)
fi

[[ -d $HOME/.nvm ]] && export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

