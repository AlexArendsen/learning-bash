#!/bin/bash

declare -A board
bwidth=0
bheight=0
mnum=0
mshow=0
CELL_NEIGHBOR_COUNT=0
CELL_IS_MINE=1
CELL_STATE=2
CELL_CHARACTER=3
CELL_EXISTS=4
CELL_COLORS="32:34:95:96:36:37:37:96"

main(){
  initialize

  while [[ cmd -ne 5 ]]; do
    print_board
    echo -ne "Minesweeper Menu
---
  [1] New Game
  [2] Show / Hide Mines
  [3] Click Cell
  [4] Flag Cell
  [5] Quit\nEnter a choice: "
    read cmd

    case $cmd in
      1)
        initialize
        ;;
      2)
        if (( mshow == 0 )); then
          mshow=1
        else
          mshow=0
        fi
        ;;
      3)
        do_click
        ;;
      4)
        do_flag
        ;;
        
    esac

  done

}

initialize(){
  echo -n "Enter board width: "
  read bwidth

  echo -n "Enter board height: "
  read bheight

  echo -n "Enter mine frequency (integer between 1 and 25): "
  read mfreq
  mnum=$(( ( bwidth * bheight * mfreq ) / 100 ))
  mnum_tmp=$mnum
  mshow=0

  # Initialize board
  for (( i = 0; i < $bwidth; i++ )); do
    for (( j = 0; j < $bheight; j++ )); do
      cell_set_neighbor_count $i $j 0
      cell_set_state $i $j h
      if (( mnum_tmp > 0 )); then
        let mnum_tmp--
        cell_set_is_mine $i $j 1
      fi
    done
  done

  # Randomize Mines
  for (( i = 0; i < bwidth; i++ )); do
    for (( j = 0; j < bheight; j++ )); do
      rx=$(( RANDOM % bwidth ))
      ry=$(( RANDOM % bheight ))
      swap_tmp=`cell_get_is_mine $i $j`
      cell_set_is_mine $i $j "`cell_get_is_mine $rx $ry`"
      cell_set_is_mine $rx $ry $swap_tmp
    done
  done

  # Assign counts to mine-adjacent cells in a really stupid hacky way
  for (( i = 0; i < bwidth; i++ )); do
    for (( j = 0; j < bheight; j++ )); do
      is_mine=`cell_get_is_mine $i $j`
      if (( is_mine == 1 )); then
        for (( k = -1; k < 2; k++ )); do
          for (( q = -1; q < 2; q++ )); do
            let kt=i+k
            let qt=j+q
            if cell_exists $kt $qt; then
              current=`cell_get_neighbor_count $kt $qt`
              cell_set_neighbor_count $kt $qt $(( current + 1 ))
            fi
          done
        done
      fi
    done
  done
  
}

print_board(){
  echo -n "     "
  for (( i = 0; i < bheight; i++ )); do
    printf "\e[90m%2d\e[0m " $i
  done
  echo
  for (( i = 0; i < bwidth; i++ )); do
    printf "\e[90m%4d\e[0m " $i
    for (( j = 0; j < bheight; j++ )); do
      s=`cell_get_state $i $j`
      if (( mshow == 1 )); then
        s=s
      fi
      cell_char=.
      case $s in
        s)
          is_mine=`cell_get_is_mine $i $j`
          if (( is_mine == 1 )); then
            cell_char="\e[41mM\e[0m"
          else
            n_count=`cell_get_neighbor_count $i $j`
            if (( $n_count == 0 )); then
              cell_char="\e[90m_\e[0m"
            else
              cell_char="\e[${CELL_COLORS:$(( 3 * $n_count )):2}m$n_count\e[0m"
            fi
          fi
          ;;
        f)
          cell_char="\e[44mF\e[0m"
      esac
      echo -ne " $cell_char "
    done
    echo 
  done
}

do_click(){
  echo -n "Enter cell column to click: "
  read click_x

  echo -n "Enter cell row to click: "
  read click_y

  m=`cell_get_is_mine $click_y $click_x`
  s=`cell_get_state $click_y $click_x`
  if [[ $s != 's' ]]; then
    if (( m == 1 )); then
      echo "You've hit a mine!"
      mshow=1
      print_board
      echo " --- GAME OVER --- "
      initialize
    else
      click_cell $click_y $click_x
    fi
  else
    echo "Error: this cell is already clicked"
  fi

}

do_flag(){
  echo -n "Enter cell column to flag: "
  read click_x

  echo -n "Enter cell row to flag: "
  read click_y

  if cell_exists $click_y $click_x; then
    s=`cell_get_state $click_y $click_x`
    if [[ $s == 's' ]]; then
      echo "You cannot flag a cell that is already shown"
    elif [[ $s == 'f' ]]; then
      cell_set_state $click_y $click_x h
    else
      cell_set_state $click_y $click_x f
    fi
  else
    echo "Error: Cell does not exist"
  fi
}

click_cell(){
  if cell_exists $1 $2; then
    s=`cell_get_state $1 $2`
    if [[ $s == "h" ]]; then
      local myx=$1
      local myy=$2
      cell_set_state $myx $myy s
      n=`cell_get_neighbor_count $1 $2`
      if (( n == 0 )); then
        local k=-1
        local q=-1
        for (( k = -1; k < 2; k++ )); do
          for (( q = -1; q < 2; q++ )); do
            local kt=$(( myx + k ))
            local qt=$(( myy + q ))
            click_cell $kt $qt
          done
        done
      fi
    fi
  fi
}

cell_exists(){
  if (( $1 < 0 )) || (( $1 >= $bwidth )) || (( $2 < 0 )) || (( $2 >= $bheight )); then
    return 1
  else
    return 0
  fi
}

# Cell Mutators and Accessors
cell_set_neighbor_count(){
  board[$1,$2,$CELL_NEIGHBOR_COUNT]=$3
}

cell_set_is_mine(){
  board[$1,$2,$CELL_IS_MINE]=$3
}

cell_set_state(){
  board[$1,$2,$CELL_STATE]=$3
}

cell_get_neighbor_count(){
  echo "${board[$1,$2,$CELL_NEIGHBOR_COUNT]}"
}

cell_get_is_mine(){
  echo "${board[$1,$2,$CELL_IS_MINE]}"
}

cell_get_state(){
  echo "${board[$1,$2,$CELL_STATE]}"
}

main
