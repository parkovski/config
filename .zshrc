local starttime=$(date "+%s%3N")

export LS_COLORS=$(cat $HOME/shared/etc/lscolors.txt)

export PATH="$HOME/shared/bin:$HOME/shared/scripts/Linux:$PATH"
if [[ -d "$HOME/bin" ]]; then
  export PATH="$HOME/bin:$PATH"
fi
if [[ -d "$HOME/local/bin" ]]; then
  export PATH="$HOME/local/bin:$PATH"
fi

which antibody &>/dev/null || eval "curl -sL git.io/antibody | sh -s"

source <(antibody init)

antibody bundle ael-code/zsh-colored-man-pages
antibody bundle chrissicool/zsh-256color
antibody bundle zdharma/fast-syntax-highlighting

export fpath=($HOME/shared/lib/sh/zcomp $fpath)
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

. $HOME/shared/lib/sh/os.sh
. $HOME/shared/lib/sh/completion.zsh
. $HOME/shared/lib/sh/prompt.zsh
. $HOME/shared/lib/sh/gh.sh
. $HOME/shared/lib/sh/pathutils.sh

if [[ "$OS_BASE" -eq "Linux" ]]; then
  if (( $IS_WSL )); then
    alias ls='ls --color=auto 2>/dev/null'
    alias ll='ls -al --color=auto 2>/dev/null'
    function start() {
      local winpath="$(wslpath -w $1)"
      shift
      cmd.exe /c start $winpath $@
    }
  else
    alias ls='ls --color=auto'
    alias ll='ls -al --color=auto'
  fi
else
  alias ls='ls -G'
  alias ll='ls -alG'
fi

local totaltime=$[$(date "+%s%3N")-$starttime]
echo "Starting zsh took $[$totaltime/1000].$[$totaltime%1000]s"
