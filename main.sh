#!/bin/bash

export SERVICE=""
export CONFIG_PATH=""
export PATHS=()
export REPLACE=""
export TRANSFORM=""

case ${1,,} in
    set) ./command.sh $@    ;;
    get) ./command.sh $@    ;;
    clone)                  ;;
    pull)                   ;;
    transform)  ./preflight.sh "t" && ./command.sh "transform"            ;;
    preflight)              ;;
esac