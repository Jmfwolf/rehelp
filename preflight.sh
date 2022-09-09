#!/bin/bash

check_init(){
    INIT= $(`yq '.initialized' ../yml/config.yml`)
    if [[ INIT != true ]]; then
    check_service && check_transform
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