#!/bin/bash

if [[ ${#1} -lt 4 ]]; then
    if [[ "$1" == "set "]]; then
        case ${2,,} in
            service)    set_service     $3  ;;
            transform)  set_transform   $3  ;;
            paths)      set_paths       $3  ;;
        esac
    elif [[ "$1" == "get" ]]; then
        case ${2,,} in
            service)    set_service     $3  ;;
            transform)  set_transform   $3  ;;
            paths)      set_paths       $3  ;;
        esac
    else
        echo "$1 is not a recognized command"
        exit 2
    fi
fi

case ${1,,} in
    transform)  transform   ;;
    clone)      clone       ;;
    *)          echo "$1 is not a recognized commmand"; exit 2  ;;
esac

transform() {
    ./preflight "t"
    parallel ::: $TRANSFORM ::: ${PATHS[@]}
}
set_transform() {
    TRANSFORM=$1
    echo "TRANSFORM has been set to $TRANSFORM"
    ./preflight "t"
}

#Todo: Clone should automatically update the config path
clone_config(){
    ./preflight.sh "c"
    git clone $(yq '.config_repo_url' ../yml/config)
    echo "Update your config path\n rehelp set paths PATH"
    exit 0
}

set_service(){
    yq -i '.service = "$1' ../yml/transform.yml
    echo "SERVICE has been set to $1" # This updates in the preflight check, probably not the best way
    ./preflight.sh "s"
    exit 0
}
get_service(){
    echo "SERVICE=$SERVICE"
    exit 0
}

get_paths(){
    echo "PATHS=$PATHS"
    exit 0
}

set_paths(){
    PATHS=$1
    echo "PATHS has been set to $PATHS"
    ./preflight.sh "p"
    exit 0
}