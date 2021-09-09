#!/bin/bash
phrase="This is a test of the emergency alert system."

printf "00:$phrase\n"
for ((i=0;i<8;i++)); do
  a=$(($i+30))
  b=$(($i+90))
  printf "\e[${a}m$a:$phrase\e[m \e[${b}m $b:$phrase\e[m\n"
done

for ((i=0;i<8;i++)); do
  a=$(($i+40))
  b=$(($i+100))
  printf "\e[${a}m$a:$phrase\e[m \e[${b}m$b:$phrase\e[m\n"
done