local starttime=$(date "+%s%4N")

export LS_COLORS=$(cat $HOME/shared/etc/lscolors.txt)

export PATH="$HOME/local/bin:$HOME/shared/bin:$HOME/.local/bin:$PATH"

which antibody &>/dev/null || eval "curl -sL git.io/antibody | sh -s - -b $HOME/local/bin"

source <(antibody init)

antibody bundle ael-code/zsh-colored-man-pages
antibody bundle chrissicool/zsh-256color
antibody bundle zdharma-continuum/fast-syntax-highlighting

export fpath=($HOME/shared/lib/sh/zcomp $fpath)
setopt cbases
setopt autocd
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

. $HOME/shared/lib/sh/os.sh
. $HOME/shared/lib/sh/completion.zsh
. $HOME/shared/lib/sh/prompt.zsh
. $HOME/shared/lib/sh/gh.sh
. $HOME/shared/lib/sh/pathutils.sh
#. $HOME/shared/lib/sh/chcl.sh

if [[ "$OS_BASE" -eq "Linux" ]]; then
  if (( $IS_WSL )); then
    if which exa >/dev/null; then
      alias ls='exa -F 2>/dev/null'
      alias la='exa -aF 2>/dev/null'
      alias ll='exa -al@Fg 2>/dev/null'
    else
      alias ls='ls -F --color=auto 2>/dev/null'
      alias la='ls -AF --color=auto 2>/dev/null'
      alias ll='ls -AlhF --color=auto 2>/dev/null'
    fi
    function start() {
      local winpath="$(wslpath -w $1)"
      shift
      pushd "$USERPROFILE"
      cmd.exe /c start "$winpath" "$@"
      popd
    }
  else
    if which exa >/dev/null; then
      alias ls='exa -F'
      alias la='exa -aF'
      alias ll='exa -al@Fg'
    else
      alias ls='ls -F --color=auto'
      alias la='ls -AF --color=auto'
      alias ll='ls -AlhF --color=auto'
    fi
  fi
else
  if which exa >/dev/null; then
    alias ls='exa -F'
    alias la='exa -aF'
    alias ll='exa -al@Fg'
  else
    alias ls='ls -FG'
    alias la='ls -AFG'
    alias ll='ls -AlhFG'
  fi
fi

local totaltime=$[$(date "+%s%4N")-$starttime]
if [[ -t 0 ]]; then
  echo "\e[G\e[2KProfile loaded in \e[32m$[$totaltime/1000].$[$totaltime%1000]s\e[m."
fi

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH="$N_PREFIX/bin:$PATH"  # Added by n-install (see http://git.io/n-install-repo).
