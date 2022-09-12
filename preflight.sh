#!/bin/bash
check_service(){

    if [[ -z "$SERVICE" ]]; then
        SERVICE=$(yq '.service' /transforms/$TRFILE)
    fi
    if [[ -z "$SERVICE" ]]; then
        echo "No valid Service found in /transforms/$TRFILE" >&2
        exit 2
    fi
    if [[ ! $(yq 'contains(service: [env(SERVICE)])' config/definitions.yml) ]]; then
        echo "Service not found if config/definitions.yml" >&2
        exit 2
    fi
    exit 0
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
        REPLACE=$(yq '.replacement_term' transforms/$TRFILE)
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
    ENV=($(yq '.environments' config/definitions.yml))
    if [[ ${#ENV[@]} ]]; then
        RES=$(printf -- '%s\n' "${ENV[@]}" | grep "$ENVIRONMENT")
        if [[ -z "$RES" ]]; then
            echo "$ENVIRONMENT is not included in the definitions provided." >&2
            exit 1
        fi
    fi
}

check_url(){
    local URL=$(yq '.repo_url' transforms/$TRFILE)
    local REG='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
    if [[ ! $URL =~ $REG ]]; then
        echo "$1 is not a valid url to clone from. Please check your URL or my regex" >&2
        exit 2
    fi
    REP="$(basename $URL)"
    exit 0
}

check_clone(){
    if [[ -z "$REPO" ]]; then
        exit 2
    elif [[ -d .clones/$REP ]]; then
        exit 3
    fi
    exit 0
}

case ${1,,} in
    c) check_clone      ;;
    e) check_env        ;;
    f) check_full       ;;
    p) check_paths      ;;
    s) check_service    ;;
    t) check_transform  ;;
esac

