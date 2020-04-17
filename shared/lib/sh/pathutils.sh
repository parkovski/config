function in() {
  pushd $1 >/dev/null 2>&1
  shift
  "$@"
  popd >/dev/null 2>&1
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
