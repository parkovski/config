function in {
  pushd $1 >/dev/null 2>&1
  shift
  "$@"
  popd >/dev/null 2>&1
}

function mkcd {
  local cmd
  local dir
  if [[ "$1" == "-p" || "$1" == "--push" ]]; then
    cmd="pushd"
    dir="$2"
  else
    cmd="cd"
    dir="$1"
  fi
  [[ ! -d "$dir" ]] && mkdir -p "$dir"
  $cmd $dir
}

function swapd {
  local dir1="$PWD"
  popd
  local dir2="$PWD"
  cd "$dir1"
  pushd "$dir2"
}

function up {
  local amt=$1
  local cmd=cd
  if [[ "$amt" == "-p" || "$amt" == "--push" ]]; then
    cmd=pushd
    amt=$2
  fi
  [[ -z "$amt" ]] && amt=1
  local s=$(printf "%${amt}s")
  $cmd ${s// /..\/}
}

function show {
  if [[ -z "$1" ]]; then
    ls -lah
  elif [[ -d "$1" ]]; then
    ls -laah "$1"
  elif [[ -f "$1" ]]; then
    cat "$1"
  else
    echo "show: not a dir or a file: $1" >&2
    return 2 # ENOENT
  fi
}
