function dev {
  local basevar=GH
  local dir=

  while [[ "$1" != "" ]]; do
    case "$1" in
      "-a") basevar=GH2;;
      "-t") dir="/3p";;
         *) dir="$dir/$1";;
    esac
    shift
  done

  if [[ -n "$ZSH_VERSION" ]]; then
    basedir=${(P)basevar}
  elif [[ -n "$BASH_VERSION" ]]; then
    basedir=${!basevar}
  fi

  if [[ -n "$basedir" ]]; then
    dir="$basedir$dir"
  else
    echo "\$$basevar not defined." >&2
    return 1
  fi

  cd $dir
}
