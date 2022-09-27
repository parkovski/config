#!/bin/bash
PASSWORD="$1"
if [ "x$PASSWORD" == "x" ]; then
  read -s -p "Password: " PASSWORD
  echo >&2
fi
SALT="$(openssl rand 3)"
SHA1="$(printf "%s%s" "$PASSWORD" "$SALT" | openssl dgst -binary -sha1)"
printf "{SSHA}%s\n" "$(printf "%s%s" "$SHA1" "$SALT" | base64)"