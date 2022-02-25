#!/bin/bash

colorline() {
  local i
  printf " $1;0  "
  for ((i=0;i<8;i++)); do
    fg=$[i+30]
    printf "\e[${fg}m $1;$fg "
  done
  for ((i=0;i<8;i++)); do
    fg=$[i+90]
    printf "\e[${fg}m $1;$fg "
  done
}

colorline "  0"
printf "\e[m\n"
for ((i=0;i<8;i++)); do
  bg=$[i+40]
  printf "\e[${bg}m"
  colorline " $bg"
  printf "\e[m\n"
done
for ((i=0;i<8;i++)); do
  bg=$[i+100]
  printf "\e[${bg}m"
  colorline $bg
  printf "\e[m\n"
done
