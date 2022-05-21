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
  local cmd=cd
  if [[ $amt == "-p" ]]; then
    cmd=pushd
    amt=$2
  fi
  [[ -z "$amt" ]] && amt=1
  local s=$(printf "%${amt}s")
  $cmd ${s// /..\/}
}

function dcat {
  if [[ "x$1" == x ]]; then
    ls -lah
  elif [[ -d "$1" ]]; then
    ls -lah $1
  else
    cat $1
  fi
}
