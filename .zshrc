export EDITOR=vim

source <(antibody init)

antibody bundle ael-code/zsh-colored-man-pages
antibody bundle chrissicool/zsh-256color
antibody bundle zdharma/fast-syntax-highlighting

export fpath=($HOME/bin/lib/zcomp $fpath)
setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
autoload -U compinit && compinit
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' menu select
#eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

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

# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
setopt prompt_subst
function precmd() {
  local prompt_gitstr=
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ "$?" -eq "0" ]]; then
    local gitstatus=$(git status --porcelain=1)
    local -A map
    local gitspace=
    local remote=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
    local ahead_str=$(git rev-list --count $remote..HEAD 2>/dev/null)
    local behind_str=$(git rev-list --count HEAD..$remote 2>/dev/null)
    prompt_gitstr="%F{3}$branch%F{8}(%f"
    if [[ "$ahead_str" -gt "0" ]]; then
      prompt_gitstr+="%F{4}+$ahead_str%f"
      if [[ "$behind_str" -gt "0" ]]; then
        prompt_gitstr+="%F{11}/%f"
      fi
      gitspace=' '
    fi
    if [[ "$behind_str" -gt "0" ]]; then
      prompt_gitstr+="%F{5}-$behind_str%f"
      gitspace=' '
    fi
    local -a items
    items=(${(f)gitstatus})
    local key
    for ((i=1; i <= $#items; i++)); do
      if [[ "${items[$i][2]}" != " " ]]; then
        key="${items[$i][2]}-"
      else
        key="${items[$i][1]}+"
      fi
      map[$key]=$[map[$key]+1]
    done
    local keys=(${(k)map})
    local gs
    local gcol
    for ((i=1; i <= $#keys; i++)); do
      key=$keys[$i]
      if [[ "${key[2]}" == "+" ]]; then
        gcol="%F{2}"
      else
        gcol="%F{1}"
      fi
      gs+="$gitspace$gcol${key[1]}${map[$key]}"
      gitspace=' '
    done
    prompt_gitstr+="$gs%F{8})%f "
  fi

  piznath=$(echo ${PWD/~/\~} | sed "s/\\([^\\/]\\)[^\\/]*\\//\\1\\//g")
  PS1="%F{10}%n%F{8}@%F{10}%m%f $prompt_gitstr%F{12}$piznath%f
%F{8}zsh%%%f "
}

. ~/bin/get-os.zsh

if [[ "$OS" == "Arch Linux" ]]; then
  export AUR=$HOME/Documents/GitHub/3rd-party/aur
fi
if [[ "$OS_BASE" -eq "Linux" ]]; then
  alias ls='ls --color'
else
  alias ls='ls -G'
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
