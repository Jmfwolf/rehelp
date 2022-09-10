#!/bin/bash
##
##
##
#
#
#
#
#
#
if [[ $(id -u) -eq 0 ]]; then
    echo "Do not run as root, that is dangerous." >&2
    exit 4
fi
export TRFILE="default.yml"
export SERVICE=""
export ENVIRONMENT=""
export CONFIG_PATH=""
export PATHS=()
export REPLACE=""
export TRANSFORM=""

case $(echo -e ${1,,} | tr -d '[:space:]') in
    use) ./command.sh $@         ;;
    get) ./command.sh $@         ;;
    clone)      ./command.sh $@  ;;
    transform)  ./command.sh $@  ;;
    *)      echo "$1 is not a recognized command" >&2
esac

