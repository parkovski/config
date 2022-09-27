# Reads these files in order from $ZDOTDIR (default $HOME):
# - .zshenv   (all shells)
# - .zprofile (login shells only, usage not preferred)
# - .zshrc    (interactive shells)
# - .zlogin   (login shells only)
# - .zlogout  (before exit)

local starttime=$(date "+%s%4N")

export COLORTERM=truecolor

if which vivid >/dev/null; then
  export LS_COLORS=$(vivid generate iceberg-dark)
else
  export LS_COLORS=$(cat $HOME/.share/etc/lscolors.txt)
fi

if ! [[ -z "$GH" ]]; then
  if ! [[ -e $GH/3rd-party/antidote ]]; then
    git clone https://github.com/mattmc3/antidote.git $GH/3rd-party/antidote
  fi

  source $GH/3rd-party/antidote/antidote.zsh
  antidote load
fi

# which antibody &>/dev/null || eval "curl -sL git.io/antibody | sh -s - -b $HOME/.local/bin"

# source <(antibody init)

# antibody bundle ael-code/zsh-colored-man-pages
# antibody bundle zdharma-continuum/fast-syntax-highlighting

export fpath=($HOME/.share/lib/sh/zcomp $fpath)
setopt cbases
setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=$HOME/.zsh_history

function zle-keymap-select() {
  if [[ $KEYMAP = vicmd ]]; then
    echo -ne "\e[1 q"
  else
    echo -ne "\e[5 q"
  fi
}
function zle-line-init() {
  zle-keymap-select
}
TRAPWINCH() {
  zle && { zle reset-prompt; zle -R }
}

zle -N zle-keymap-select
zle -N zle-line-init
zle -N edit-command-line

bindkey -v

autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

bindkey '^p' up-history
bindkey '^n' down-history

bindkey '^r' history-incremental-search-backward

bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

bindkey '^k' vi-kill-line

. $HOME/.share/lib/sh/os.sh
. $HOME/.share/lib/sh/completion.zsh
. $HOME/.share/lib/sh/prompt.zsh
. $HOME/.share/lib/sh/pathutils.sh
. $HOME/.share/lib/sh/gh.sh
. $HOME/.share/lib/sh/os-alias.sh
#. $HOME/.share/lib/sh/chcl.sh

if [[ -t 0 ]]; then
  local totaltime=$[$(date "+%s%4N")-$starttime]
  echo "\e[G\e[2KProfile loaded in \e[32m$[$totaltime/1000].$[$totaltime%1000]s\e[m."
fi

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH="$N_PREFIX/bin:$PATH"  # Added by n-install (see http://git.io/n-install-repo).
