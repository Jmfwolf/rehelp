#!/bin/bash

case ${1,,} in
    e) check_env        ;;
    f) check_full       ;;
    p) check_paths      ;;
    s) check_service    ;;
    t) check_transform  ;;
esac


check_full(){
    INIT=$(yq '.initialized' .yml/config.yml)
    if [[ INIT != true ]]; then
       check_service && check_transform && check_env && check_replace && check_transform
    if [[ -z "$(which yq)" ]]; then
        echo "Please use your package manager to install yq\ne.g. brew install yq" >&2
    fi
    if [[ -z "$(which parallel)" ]]; then
        echo "Please use your package manager to install yq\ne.g. brew install parallel" >&2
    fi
}

check_service(){
    if [[ -z "$SERVICE" ]]; then
        SERVICE=$(yq '.service' ../transforms/$TRFILE)
    fi
    if [[ -z "$SERVICE" ]]; then
        echo "Please enter a service"
        read SERVICE
        ./command.sh use service "$SERVICE"
    fi
}


check_paths(){
    if [[ -z "$CONFIG_PATH" ]]; then
        CONFIG_PATH=$(yq '.path' ../transforms/$TRFILE)
    fi
    if [[ -z "$CONFIG_PATH" ]]; then
        echo "There is no config file to change. Would you like to clone the repo? y/n"
        read ans
        if [[ "${ans,,}" == "y" ]]; then
            ./command.sh clone
        fi
        exit 1
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
        REPLACE=$(yq '.replacement_term' ../transforms/$TRFILE)
    fi
    if [[ -z "$REPLACE" ]]; then
        echo "Please use the replace value\n rehelp use replace REPLACEVALUE" >&2
        exit 1
    fi
}

check_transform(){
    if [[ -z "$TRANSFORM" ]]; then
        TRANSFORM="yq -i '(.images[] | select(. == ".registry/$SERVICE").newTag) = "$REPLACE"'"
    fi
    if [[ -z "$TRANSFORM" ]]; then
        echo "Someone didn't listen to warnings. You should pull this repo again.\nDon't alter the transform value if you aren't sure what you are doing" >&2
        exit 1
    fi
}

check_env(){
    ENV=($(yq '.environments' ../transforms/definitions.yml))
    if [[ ${#ENV[@]} ]]; then
        RES=$(printf -- '%s\n' "${ENV[@]}" | grep "$ENVIRONMENT")
        if [[ -z "$RES" ]]; then
            echo "$ENVIRONMENT is not included in the definitions provided." >&2
            exit 1
        fi
    fi
}
