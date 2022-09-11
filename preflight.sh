#!/bin/bash

check_service(){
    local SERVICE=$1
    if [[ -z "$SERVICE" ]]; then
        echo "There is no value in service.\nservice value is required" >&2
        exit 2
    fi
}


check_paths(){
    local SERVICE=$1
    local ENVIRONMENT=$2
    local REPO=$3
    if [[ ! ${#PATHS} ]]; then
        PATHS=($(yq '.services.env(SERVICE).env(ENVIRONMENT).[] .clones/env(REPO)'))
    fi
    if [[ ! ${#PATHS} ]]; then
        echo "Path error: You may want to check if the repo url is valid or the definitions provided are correct." >&2
        exit 2
    fi
}

verify_paths(){

    check_paths $1  $2  $3

    for i in "${!PATHS[@]}"; do
        if [[ ! -e "${PATHS[$i]}" ]]; then
            echo "${PATHS[$i]} was not found. Please check the $TRFILE" >&2
            unset PATHS[i]
        fi
    done
}

check_replace(){
    local REPLACE=$1
    if [[ -z "$REPLACE" ]]; then
        echo "There is no value in replace.\nreplace value is required" >&2
        exit 2
    fi
}

check_transform(){
    local TRANSFORM=$1
    if [[ -z "$TRANSFORM" ]]; then
        echo "There is no value in transform.\ntranform value is required" >&2
        exit 2
    fi
}

check_env(){
    local ENVIRONMENT=$1
    local ENV=($(yq '.environments' /transforms/definitions.yml))
    if [[ -z "$ENVIRONMENT" ]]; then
        echo -e "There is no value in environment.\nenvironment is a required value" >&2
    if [[ ${#ENV[@]} ]]; then
        RES=$(printf -- '%s\n' "${ENV[@]}" | grep "$ENVIRONMENT")
        if [[ -z "$RES" ]]; then
            echo "$ENVIRONMENT is not included in the definitions provided." >&2
            exit 2
        fi
    fi
}

check_clone_url(){
    local URL=$1
    local REG='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
    if [[ ! $URL =~ $REG ]]; then
        echo "$1 is not a valid url to clone from. Please check your URL or my regex"
        exit 2
    fi
}


case ${1,,} in
    c) check_clone_url  $2          ;;
    e) check_env        $2          ;;
    p) check_paths      $2  $3  $4  ;;
    s) check_service    $2          ;;
    t) check_transform  $2          ;;
    v) verify_paths     $2  $3  $4  ;;
esac

