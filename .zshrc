# Reads these files in order from $ZDOTDIR (default $HOME):
# - .zshenv   (all shells)
# - .zprofile (login shells only, usage not preferred)
# - .zshrc    (interactive shells)
# - .zlogin   (login shells only)
# - .zlogout  (before exit)

setopt cbases
setopt histignorealldups extendedhistory incappendhistorytime
setopt noflowcontrol
setopt promptsubst
setopt longlistjobs notify
setopt nonomatch
setopt hashlistall
setopt completeinword
setopt noshwordsplit
setopt interactivecomments

export fpath=($HOME/.share/lib/sh/zcomp $fpath)
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=$HOME/.zsh_history

export COLORTERM=truecolor

# List themes with `vivid themes`
# Generate new theme with `vivid generate <name> > ~/.local/etc/lscolors.txt`
if [[ -f $HOME/.local/etc/lscolors.txt ]] then
  export LS_COLORS=$(cat $HOME/.local/etc/lscolors.txt)
elif [[ -f "$HOME/.share/etc/lscolors.txt" ]]; then
  export LS_COLORS=$(cat $HOME/.share/etc/lscolors.txt)
fi

if ! [[ -z "$GH" ]]; then
  if ! [[ -e "$GH/3p/antidote" ]]; then
    git clone https://github.com/mattmc3/antidote.git $GH/3p/antidote
  fi

  source $GH/3p/antidote/antidote.zsh
  antidote load
fi

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

if [[ -d $HOME/.share/lib/sh ]]; then
  source $HOME/.share/lib/sh/os.sh
  source $HOME/.share/lib/sh/completion.zsh
  source $HOME/.share/lib/sh/prompt.zsh
  source $HOME/.share/lib/sh/pathutils.sh
  source $HOME/.share/lib/sh/gh.sh
  source $HOME/.share/lib/sh/os-alias.sh
  #source $HOME/.share/lib/sh/chcl.sh
fi

. /opt/asdf-vm/asdf.sh

# pnpm
export PNPM_HOME="/home/parker/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end