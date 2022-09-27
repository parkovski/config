#!/bin/bash

if [[ "$1" == "-n" ]]; then
  nonr=1
else
  nonr=0
fi

putcell() {
  if [[ $nonr == 1 ]]; then
    local n=' '
  else
    local n=$1
  fi
  printf "\e[48;5;$1m %$2s " $n
}

for ((i=0; i<2; i++)); do
  for ((j=0; j<8; j++)); do
    n=$[$i*8+$j]
    case $n in
      [1-79]|1[0-5]) printf "\e[30m";;
    esac
    putcell $n 2
    # printf "\e[48;5;${n}m %2s \e[m" $n
  done
  printf "\e[m\n"
done
echo

x=0
for ((i=0; i<20; i++)); do
  y=$[16 + $x + $i*6]
  [[ $i == 19 ]] && y=$[$y + 6]

  case $i in
    [34589]|1[013-79]) blk=1;;
    *) blk=0;;
  esac

  [[ $blk == 1 ]] && printf "\e[30m"
  for ((j=0; j<6; j++)); do
    n=$[$y + $j]
    putcell $n 3
    # printf "\e[48;5;${n}m %3s " $n
  done
  # printf "\e[m∥"
  printf "\e[m|"

  if [[ $i -lt 18 ]]; then
    y=$[$y + 36]
  else
    y=$[$y + 6]
  fi

  [[ $blk == 1 ]] && printf "\e[30m"
  for ((j=0; j<6; j++)); do
    n=$[$y + $j]
    putcell $n 3
    #printf "\e[48;5;${n}m %3s " $n
  done
  printf "\e[m\n"

  if [[ $[$i % 6] == 5 ]]; then
    x=$[$x + 36]
    if [[ $i == 17 ]]; then
      # printf "==============================×==============================\n"
      printf -- "------------------------------+------------------------------\n"
      # printf "  ×    ×    ×    ×    ×    ×  ∥  ×    ×    ×    ×    ×    ×  \n"
      # printf "\e[48;5;255m\e[38;5;232m⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯∥"
      # printf "\e[48;5;255m\e[38;5;232m⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\e[m\n"
    fi
  fi
done
