if [[ "$OS_BASE" == Linux ]]; then
  local wslignore
  if [[ "$IS_WSL" == 1 ]]; then
    wslignore=" 2>/dev/null"
    function start {
      local winpath="$(wslpath -w $1)"
      shift
      pushd "$USERPROFILE"
      cmd.exe /c start "$winpath" "$@"
      popd
    }
  else
    function start {
      xdg-open "$1" >/dev/null 2>&1
    }
  fi

  if which exa >/dev/null; then
    alias ls="exa -F$wslignore"
    alias la="exa -aF$wslignore"
    alias ll="exa -al@Fg$wslignore"
  else
    alias ls="ls -F --color=auto$wslignore"
    alias la="ls -AF --color=auto$wslignore"
    alias ll="ls -AlhF --color=auto$wslignore"
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

if which bat >/dev/null; then
  alias cat=bat
fi
