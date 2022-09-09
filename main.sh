#!/bin/bash

export SERVICE=""
export ENVIRONMENT=""
export CONFIG_PATH=""
export PATHS=()
export REPLACE=""
export TRANSFORM=""

case ${1,,} in
    set) ./command.sh $@         ;;
    get) ./command.sh $@         ;;
    clone)      ./command.sh $@  ;;
    transform)  ./command.sh $@  ;;
esac

