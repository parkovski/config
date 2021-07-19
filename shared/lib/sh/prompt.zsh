setopt prompt_subst
function precmd() {
  local exitcode="$?"
  if [[ "$exitcode" -eq "0" ]]; then
    exitcode=
  else
    exitcode="[%F{1}$exitcode%F{8}] "
  fi
  local prompt_gitstr=

  if [[ "$PROMPT_GIT" ]]; then
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
  fi

  local piznath=$(echo -n ${PWD/#~/\~} | sed "s/\\([^\\/]\\)[^\\/]*\\//\\1\\//g")
  print -P "%F{10}%n%F{8}@%F{10}%m%f$prompt_gitstr %F{12}$piznath%f"
  PS1="%F{8}${exitcode}zsh%%%f "
}
