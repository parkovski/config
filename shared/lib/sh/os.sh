OS_BASE=$(uname -s)
if [[ $OS_BASE == Darwin ]]; then
  OS_BASE=macOS
fi
if [[ -f /etc/os-release ]]; then
  OS=$(cat /etc/os-release | sed -n "s/^NAME=\\\"\\(.\\+\\)\\\"/\\1/p")
elif [[ $(uname -o) == Android ]]; then
  OS=Android
else
  OS=$OS_BASE
fi
export OS_BASE
export OS

if [[ $OS_BASE == Linux ]]; then
  cat /proc/version 2>/dev/null | grep -iq Microsoft
  export IS_WSL=$[! $?]
fi
