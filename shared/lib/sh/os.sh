OS_BASE=$(uname -s)
if [[ "$OS_BASE" == "Darwin" ]]; then
  OS_BASE="macOS"
fi
if [[ -f /etc/os-release ]]; then
  OS=$(cat /etc/os-release | sed -n "s/^NAME=\\\"\\(.\\+\\)\\\"/\\1/p")
else
  OS=$OS_BASE
fi
export OS_BASE
export OS

if [[ "$OS_BASE" -eq "Linux" ]]; then
  cat /proc/version | grep -iq Microsoft
  export IS_WSL=$[! $?]
fi
