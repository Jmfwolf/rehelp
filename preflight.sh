#!/bin/bash

case ${1,,} in
    f) check_full       ;;
    i) check_init       ;;
    p) check_paths      ;;
    s) check_service    ;;
    t) check_transform  ;;

esac


check_init(){
    INIT= $(`yq '.initialized' ../yml/config.yml`)
    if [[ INIT != true ]]; then
    check_service && check_transform
    if [[ -z "$(which yq)" ]]; then
        echo "Please use your package manager to install yq\ne.g. brew install yq"
    fi
    if [[ -z "$(which parallel)" ]]; then
        echo "Please use your package manager to install yq\ne.g. brew install parallel"
    fi
}

check_service(){
    if [[ -z "$SERVICE" ]]; then
        SERVICE=$(yq '.service' ../yml/transform.yml)
    fi
    if [[ -z "$SERVICE" ]]; then
        echo "Please set the service\n rehelp set service SERVICENAME"
        exit 1
    fi
}


check_paths(){
    if [[ -z "$CONFIG_PATH" ]]; then
        CONFIG_PATH=$(yq '.path' ../yml/transform.yml)
    fi
    if [[ -z "$CONFIG_PATH" ]]; then
        echo "Please Set the Path to the Configuration repo\n rehelp set path PATH"
        exit 1
    fi

}

verify_paths(){

    check_paths

    for i in "${!PATHS[@]}"; do
        if [[ ! -e "${PATHS[$i]}" ]]; then
            echo "${PATHS[$i]} was not found. Please check the definitions.yml"
            unset PATHS[i]
        fi
    done
}

check_replace(){
    if [[ -z "$REPLACE" ]]; then
        REPLACE=$(yq '.replacement_term' ../yml/transform.yml)
    fi
    if [[ -z "$REPLACE" ]]; then
        echo "Please set the replace value\n rehelp set replace REPLACEVALUE"
        exit 1
    fi
}

check_transform(){
    if [[ -z "$TRANSFORM" ]]; then
        TRANSFORM="yq -i '(.images[] | select(. == ".registry/$SERVICE").newTag) = "$REPLACE"'"
    fi
    if [[ -z "$TRANSFORM" ]]; then
        echo "Someone didn't listen to warnings. You should pull this repo again.\nDon't alter the transform value if you aren't sure what you are doing"
        exit 1
    fi
}

check_full(){
    check_init && check_service && check_replace && check_paths
    check_transform
}