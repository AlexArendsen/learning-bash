#!/bin/bash

height=15
delta=1
numspaces=0
numstars=1
star_idx=1
half=$(( height / 2 ))

for (( y=0; y<height; y++ )); do

  numspaces=$(( ( half - y ) * delta  ))
  numstars=$(( ( 2 * star_idx ) - 1 ))
  
  for (( x=0; x < numspaces; x++ )); do
    echo -n " "
  done

  for (( ; x < numspaces + numstars; x++ )); do
    echo -n "*"
  done

  if (( y == half )); then
    delta=$(( delta * -1 ))
  fi

  star_idx=$(( star_idx + delta ))

  echo ""

done
