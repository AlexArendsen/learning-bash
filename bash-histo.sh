#!/bin/bash

# Two Perl functions for character-integer conversion
chr(){
  echo `perl -CA -le 'print chr shift' $1`
}

ord(){
  echo `perl -CA -le 'print ord shift' $1`
}

echo -n "Enter a string: "
read src

# Convert to lowercase
src=${src,,}
base=`ord "a"`

# Initialize array
for (( i=0; i<26; i++ )); do
  let freq[i]=0
done

# Fill array
for (( i=0; i<${#src}; i++ )); do
  code=`ord "${src:$i:1}"`
  idx=$(( code - base ))
  if (( idx > -1 )) && (( idx < 26 )); then
    let freq[idx]++
  fi
done

# Output
for (( i = 0; i < 26; i++ )); do
  char=`chr $(( i + base ))`
  el="${freq[$i]}"
  echo -n "${char^^} | "
  for (( j = 0; j < el; j++ )); do
    echo -n "*"
  done
  echo
done
