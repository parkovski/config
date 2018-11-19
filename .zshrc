local starttime=$(date "+%s%3N")
export EDITOR=vim

export LS_COLORS=$(cat ~/shared/etc/lscolors.txt)

which antibody &>/dev/null || eval "curl -sL git.io/antibody | sh -s"

source <(antibody init)

antibody bundle ael-code/zsh-colored-man-pages
antibody bundle chrissicool/zsh-256color
antibody bundle zdharma/fast-syntax-highlighting

export fpath=($HOME/shared/lib/zcomp $fpath)
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

# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
setopt prompt_subst
function precmd() {
  local exitcode="$?"
  if [[ "$exitcode" -eq "0" ]]; then
    exitcode=
  else
    exitcode="[%F{1}$exitcode%F{8}] "
  fi
  local prompt_gitstr=
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ "$?" -eq "0" ]]; then
    local gitstatus=$(git status --porcelain)
    local -A map
    local gitspace=
    local remote=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
    local ahead_str=$(git rev-list --count $remote..HEAD 2>/dev/null)
    local behind_str=$(git rev-list --count HEAD..$remote 2>/dev/null)
    prompt_gitstr=" %F{3}$branch%F{8}:%f"
    if [[ "$ahead_str" -gt "0" ]]; then
      prompt_gitstr+=" %F{4}+$ahead_str"
      if [[ "$behind_str" -gt "0" ]]; then
        prompt_gitstr+="%F{11}/%F{5}-$behind_str%F{8}:%f"
      else
        prompt_gitstr+="%F{8}:%f"
      fi
    elif [[ "$behind_str" -gt "0" ]]; then
      prompt_gitstr+=" %F{5}-$behind_str%F{8}:%f"
    fi
    local -a items
    items=(${(f)gitstatus})
    local key
    for ((i=1; i <= $#items; i++)); do
      if [[ "${items[$i][1]}" == "?" ]]; then
        key="??"
      elif [[ "${items[$i][2]}" != " " ]]; then
        key="${items[$i][2]}-"
      else
        key="${items[$i][1]}+"
      fi
      map[$key]=$[map[$key]+1]
    done
    local keys=(${(k)map})
    local gcol
    for ((i=1; i <= $#keys; i++)); do
      key=$keys[$i]
      if [[ "${key[2]}" == "+" ]]; then
        # gcol="%F{2}"
        gcol=$'%{\e[38;5;35m%}'
      elif [[ "$key" == "??" ]]; then
        gcol=$'%{\e[38;5;202m%}'
      else
        # gcol="%F{1}"
        gcol=$'%{\e[38;5;160m%}'
      fi
      prompt_gitstr+=" $gcol${key[1]}${map[$key]}"
    done
    if [[ "$#keys" -gt "0" ]]; then
      prompt_gitstr+="%F{8}:%f"
    fi
  fi

  local piznath=$(echo -n ${PWD/~/\~} | sed "s/\\([^\\/]\\)[^\\/]*\\//\\1\\//g")
  print -P "%F{10}%n%F{8}@%F{10}%m%f$prompt_gitstr %F{12}$piznath%f"
  PS1="%F{8}${exitcode}zsh%%%f "
}

. ~/shared/lib/get-os.zsh

if [[ "$OS" == "Arch Linux" ]]; then
  export AUR=$HOME/Documents/GitHub/3rd-party/aur
fi
if [[ "$OS_BASE" -eq "Linux" ]]; then
  if (( $IS_WSL )); then
    alias ls='ls --color 2>/dev/null'
  else
    alias ls='ls --color'
  fi
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

function mkcd {
  local cmd
  local dir
  if [[ "$1" == "-p" ]]; then
    cmd="pushd"
    dir="$2"
  else
    cmd="cd"
    dir="$1"
  fi
  [[ ! -d "$dir" ]] && mkdir -p "$dir"
  $cmd $dir
}

function up {
  local amt=$1
  [[ ! $amt ]] && amt=1
  local s=$(printf "%${amt}s")
  cd ${s// /..\/}
}

export PATH="$HOME/local/bin:$HOME/shared/bin:$HOME/shared/scripts/Linux:$PATH"

local totaltime=$[$(date "+%s%3N")-$starttime]
echo "Starting zsh took $[$totaltime/1000].$[$totaltime%1000]s"

