#!/bin/bash

check_service(){
    if [[ -z "$SERVICE" ]]; then
        SERVICE=$(yq '.service' /transforms/$TRFILE)
    fi
    if [[ -z "$SERVICE" ]]; then
        echo "Please enter a service"
        read SERVICE
        ./command.sh use service "$SERVICE"
    fi
}


check_paths(){
    if [[ ! ${#PATHS} ]]; then
        PATHS=($(yq '.services.[env(SERVICE)].[env(ENVIRONMENT)].[] .clones/env(REPO)'))
    fi
    if [[ ! ${#PATHS} ]]; then
        echo "Path error: You may want to check if the repo url is valid or the definitions provided are correct." >&2
    fi
}

verify_paths(){

    check_paths

    for i in "${!PATHS[@]}"; do
        if [[ ! -e "${PATHS[$i]}" ]]; then
            echo "${PATHS[$i]} was not found. Please check the $TRFILE" >&2
            unset PATHS[i]
        fi
    done
}

check_replace(){
    if [[ -z "$REPLACE" ]]; then
        REPLACE=$(yq '.replacement_term' /transforms/$TRFILE)
    fi
    if [[ -z "$REPLACE" ]]; then
        echo "Please use the replace value\n rehelp use replace REPLACEVALUE" >&2
        exit 1
    fi
}

check_transform(){
    if [[ -z "$TRANSFORM" ]]; then
        TRANSFORM="yq (.transform )"
    fi
    if [[ -z "$TRANSFORM" ]]; then
        echo "Someone didn't listen to warnings. You should pull this repo again.\nDon't alter the transform value if you aren't sure what you are doing" >&2
        exit 1
    fi
}

check_env(){
    ENV=($(yq '.environments' /transforms/definitions.yml))
    if [[ ${#ENV[@]} ]]; then
        RES=$(printf -- '%s\n' "${ENV[@]}" | grep "$ENVIRONMENT")
        if [[ -z "$RES" ]]; then
            echo "$ENVIRONMENT is not included in the definitions provided." >&2
            exit 1
        fi
    fi
}

case ${1,,} in
    e) check_env        ;;
    f) check_full       ;;
    p) check_paths      ;;
    s) check_service    ;;
    t) check_transform  ;;
esac

