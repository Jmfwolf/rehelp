#!/bin/bash
mkdir ~/.rehelp


declare -A DEPEND;
DEPEND[parallel]=$(which parallel) &
DEPEND[git]=$(which git) &
DEPEND[yq]=$(which yq) &

for app in ${!DEPEND[@]}; do
    if [[ -z "${DEPEND[$app]}" ]]; then


case $OSTYPE in
    linux*)                 ;;
    darwin*)                ;;
    *)                      ;;
esac