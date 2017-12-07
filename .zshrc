export EDITOR=vim

source <(antibody init)

antibody bundle ael-code/zsh-colored-man-pages
antibody bundle chrissicool/zsh-256color
antibody bundle zdharma/fast-syntax-highlighting

ls --color / &>/dev/null
if [[ "$?" -eq "0" ]]; then
  alias ls='ls --color'
else
  alias ls='ls -G'
fi

export fpath=($HOME/bin/lib/zcomp $fpath)
autoload -U compinit && compinit
zstyle ':completion:*' menu select

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
  zle && zle -R
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

setopt prompt_subst
function precmd() {
  local prompt_gitstr=
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ "$?" -eq "0" ]]; then
    local remote=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
    local ahead_str=$(git rev-list --count $remote..HEAD 2>/dev/null)
    local behind_str=$(git rev-list --count HEAD..$remote 2>/dev/null)
    prompt_gitstr="%F{yellow}$branch(%f"
    if [[ "$ahead_str" -gt "0" ]]; then
      prompt_gitstr+="%F{green}+$ahead_str%f"
      if [[ "$behind_str" -gt "0" ]]; then
        prompt_gitstr+="%F{yellow}/%f"
      fi
    fi
    if [[ "$behind_str" -gt "0" ]]; then
      prompt_gitstr+="%F{magenta}-$behind_str%f"
    fi
    prompt_gitstr+="%F{yellow})%f "
  fi

  piznath=$(echo ${PWD/~/\~} | sed "s/\\([^\\/]\\)[^\\/]*\\//\\1\\//g")
  PS1="%F{green}%n%F{gray}@%F{green}%m%f $prompt_gitstr%F{blue}$piznath%f %% "
}

. ~/bin/get-os.zsh

if [[ "$OS" == "Arch Linux" ]]; then
  export AUR=$HOME/Documents/GitHub/3rd-party/aur
fi

export GH=$HOME/Documents/GitHub
function gh() {
  local dir=$1
  if [[ "$1" == "-t" ]]; then
    dir="3rd-party/$2"
  elif [[ "$AUR" != "" && "$1" == "-aur" ]]; then
    dir="3rd-party/aur/$2"
  elif [[ "$1" == "-n" ]]; then
    mkdir "$GH/$2"
    cd "$GH/$2"
    git init
    dir=
  elif [[ "$1" == "" ]]; then
    cd $GH
  fi
  if [[ "$dir" != "" ]]; then
    cd "$GH/$dir"
  fi
}

export PATH="$HOME/bin:$PATH"

[[ -f /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
