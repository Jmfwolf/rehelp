#!/bin/bash

export SERVICE=""
export CONFIG_PATH=""
export PATHS=()
export REPLACE=""
export TRANSFORM=""

if [[ "${#1}" -le 4 ]]; then
    ./command.sh $@
    exit 0
fi

if [[ "$1" == "transform" ]]; then
    