#!/bin/bash

isprime(){
  out=0
  n=$1

  for (( j = 2; j < n; j++ )); do
    if (( ( n % j ) == 0 )); then
      out=1
      break
    fi
  done

  if (( n == 1 )); then
    out=1
  fi

  return $out
}

echo -n "How many days in the month: "
read dim

echo -n "On which day does this month begin? (1=Sun, 7=Sat) "
read dow

dow=$(( dow - 1 ))

for (( i = 0; i < dow; i++ )); do
  echo -n "    "
done

for (( i = 1; i <= dim; i++ )); do
  if isprime $i; then
    flag="*"
  else
    flag=" "
  fi
  printf "%2d%s " "$i" "$flag"
  dow=$(( dow + 1 ))
  if (( dow >= 7 )); then
    dow=0
    echo ""
  fi
done

echo "";

