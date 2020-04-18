function gh() {
  if [[ "$GH" == "" ]]; then
    echo "\$GH not defined." >&2
    return 1
  fi

  if [[ "$1" == "-t" ]]; then
    cd "$GH/3rd-party/$2"
  elif [[ "$1" == "-n" ]]; then
    mkdir "$GH/$2"
    cd "$GH/$2"
    git init
  else
    cd "$GH/$1"
  fi
}
