function chcl {
  if [ -n "$ZSH_VERSION" ]; then
    script_name="${(%):-%x}"
  elif [ -n "$BASH_VERSION" ]; then
    script_name="${BASH_SOURCE[0]}"
  else
    script_name="$0"
  fi
  script_dir=$(dirname $script_name)

  source <($script_dir/chcl.js "$@")
}
