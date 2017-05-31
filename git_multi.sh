#!/bin/bash

BAR_WIDTH=80
HALF_BAR_WIDTH=$((BAR_WIDTH/2))

IFS=$'\r\n'
GLOBIGNORE='*'
REPOS=()
CONFIRM=1

function dirs {
    REPOS=( $(find . -name .git -mindepth 2 -maxdepth 2 -type d | sed 's/.\{4\}$//') )
}

function title {
    name=$(echo $1 | sed 's/[^a-zA-Z0-9]//g')
    bar_length=$(($HALF_BAR_WIDTH-2))
    length=${#name}
    half_length=$(($length/2))
    printf "%.s-" $(seq 1 $(($bar_length-$half_length)))
    printf ">"
    printf '\e[1;34m%-6s\e[m'  " $name "
    printf "<"
    printf "%.s-" $(seq 1 $(($bar_length-($length-$half_length))))
    echo
}

function confirm {
    read -p "$1" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        return 0
    fi
    return 1
}

while [[ $1 = -?* ]]; do
    case $1 in
        -h|--help)
            exit 0
            ;;
        -a|--all)
            dirs
            ;;
        -f|--force)
            CONFIRM=0
            ;;
        -af|-fa)
            CONFIRM=0
            dirs
            ;;
        *)
            ;;
    esac
    shift
done

if [ "${#REPOS[@]}" -lt 1 ]; then 
    if [ ! -f $PWD/.gitmulti ]; then
        if [ -d .git ]; then
            git "$@"
            exit
        fi

        echo "error: no repositories"
        echo "help: specify repositories in a '.gitmulti' file or by using the '-a' parameter"
        exit 0
    fi
    REPOS=($(cat $PWD/.gitmulti)) 
fi

if [ "$#" -lt 1 ]; then
    echo "error: illegal number of parameters"
    exit 0
fi

printf "%.s=" $(seq 1 $BAR_WIDTH)
echo

for dir in "${REPOS[@]}"
do
    title $dir

    if [ $CONFIRM -eq 1 ] ; then
        if confirm "Are you sure you want to execute the ($1) command in the ($dir) repository? " ; then
            continue
        fi
    fi

    cd $dir
    git "$@"
    cd ..
done

printf "%.s=" $(seq 1 $BAR_WIDTH)
echo
