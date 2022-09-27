#!/bin/bash
mkpasswd=$(dirname ${BASH_SOURCE[0]})/ssha-passwd.sh
if [ -f .htpasswd ]; then
  if [ x"$1" != "x-f" ]; then
    echo ".htpasswd already exists; -f to overwrite." >&2
    exit 1
  fi
fi
read -p "Username: " USERNAME
PASSWORD=$($mkpasswd)
echo "$USERNAME:$PASSWORD" > .htpasswd
echo ok