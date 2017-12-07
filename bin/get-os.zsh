OS_BASE=$(uname -s)
if [[ "$OS_BASE" -eq "Darwin" ]]; then
  OS_BASE="macOS"
fi
if [[ -f /etc/os-release ]]; then
  OS=$(cat /etc/os-release | sed -n "s/^NAME=\\\"\\(.\\+\\)\\\"/\\1/p")
else
  OS=$OS_BASE
fi
