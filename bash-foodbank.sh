#!/bin/bash

inventory_max=100
declare -a donation_count
declare -a donation_lookup
declare -a request_count
declare -a request_lookup

main(){
  cmd=0
  
  while (( cmd != 5 )); do
    echo -ne "Welcome to the foodbank!\n
  [1] Make a Donation
  [2] Make a Request
  [3] Fulfill a Request
  [4] Print a Status Report
  [5] Exit\n
Enter A Choice: "
    read cmd
  
    case $cmd in
      1)
        push_donation
        ;;
      2)
        push_request
        ;;
      3)
        pop_request
        ;;
      4)
        print_report
        ;;
      5)
        echo "Thank you for using the software. Bye for now!"
        ;;
    esac
  done
}

donation_index(){
  name=$1
  out=-1
  index=0
  for n in "${donation_lookup[@]}"; do
    if [[ $n == $name ]]; then
      let out=index
      break
    fi
    let index++
  done
  echo $out
}

push_donation(){
  echo -n "What kind of food are you donating? "
  read don_type

  echo -n "How much / many $don_type are you donating? "
  read don_count

  idx=`donation_index $don_type`
  if (( idx == -1 )); then
    idx=${#donation_lookup[@]}
    donation_lookup[$idx]=$don_type
  fi
  donation_count[$idx]=$(( donation_count[idx] + don_count ))
}

push_request(){
  echo -n "What kind of food are you requesting? "
  read req_type

  echo -n "How much / many of $req_type are you requesting? "
  read req_count

  idx=${#request_lookup[@]}
  request_lookup[$idx]=$req_type
  request_count[$idx]=$req_count
}

pop_request(){
  req_count=${#request_count[@]}
  don_count=${#donation_count[@]}
  if (( req_count == 0 )); then
    echo "No requests to fill!"
    return
  fi

  don_idx=`donation_index "${request_lookup[0]}"`
  if (( don_idx == -1 )); then
    echo "Cannot fulfill request"
    return
  fi

  while (( ${request_count[0]} > 0 )) && (( ${donation_count[$don_idx]} > 0 )); do
    let donation_count[don_idx]--
    let request_count[0]--
  done

  if (( ${request_count[0]} == 0 )); then
    for (( i = 1; i < req_count; i++ )); do
      let request_count[i-1]=request_count[i]
      request_lookup[$(( i - 1 ))]=${request_lookup[$i]}
    done
    unset request_count[$((req_count - 1))]
    unset request_lookup[$((req_count - 1))]
  fi

  if (( ${donation_count[$don_idx]} == 0 )); then
    for (( i = don_idx + 1; i < don_count; i++ )); do
      let donation_count[i-1]=donation_count[i]
      donation_lookup[$(( i - 1 ))]=${donation_lookup[$i]}
    done
    unset donation_count[$((don_count - 1))]
    unset donation_lookup[$((don_count - 1))]
  fi
}

print_report(){
  echo "Donations"
  echo " -----------------------------"
  for (( i = 0; i < ${#donation_lookup[@]}; i++ )); do
    printf "| %20s | %4d |\n" "${donation_lookup[$i]}" "${donation_count[$i]}"
  done
  echo " -----------------------------"

  echo "Requests"
  echo " -----------------------------"
  for (( i = 0; i < ${#request_lookup[@]}; i++ )); do
    printf "| %20s | %4d |\n" "${request_lookup[$i]}" "${request_count[$i]}"
  done
  echo " -----------------------------"
}

main
