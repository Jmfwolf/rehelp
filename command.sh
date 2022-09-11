#!/bin/bash
transform() {
    ./preflight.sh "t"
    local ENVIRONMENT=$(get_var "environment")
    local TRANSFORM=$(get_var "transform")
    git checkout $ENVIRONMENT
    git checkout -b 
    (cd .clones && echo $TRANSFORM && parallel ::: $TRANSFORM ::: ${PATHS[@]})
}

clone_repo(){
    ./preflight.sh "c"
    local TEMP=$(yq '.repo_url' transforms/$TRFILE)
    (cd .clones && git clone $TEMP)
    REPO="$(basename $TEMP)"
    exit 0
}

use_VAR(){
    local VAR_NAME=$(echo -e ${1,,} | tr -d '[:space:]')
    local VAR_VALUE=$(echo -e ${2,,} | tr -d '[:space:]')
    if [[ -z $(yq '.env(VAR_NAME)' transforms/$TRFILE) ]]; then
        echo "$VAR was not found in $TRFILE, would you like to write and set it? y/n"
        read -n 1 ANS
        if [[ ! "${ANS,,}" == "y"]]; then
            echo "$VAR_NAME not set exit"
            exit 1
        fi
    fi
    yq -i '.env(VAR) = env(VAR)' transforms/$TRFILE
    echo "$VAR_NAME has been set to $VAR_VALUE"
    exit 0
}
get_VAR(){
    local VAR=$(echo -e ${1,,} | tr -d '[:space:]')
    echo "$VAR: $(yq '.env(VAR)' transforms/$TRFILE)"
    exit 0
}

if [[ ${#1} -lt 4 ]]; then
    if [[ "${1,,}" == "use" ]]; then
        case ${2,,} in
            service)    use_service     $3  ;;
            transform)  use_transform   $3  ;;
            paths)      use_paths       $3  ;;
            environ)    use_env         $3  ;;
            repo)       use_repo        $3  ;;
            *)          echo "$2 is not a recognized command" >&2; exit 2   ;;
        esac
    elif [[ "${1,,}" == "get" ]]; then
        case ${2,,} in
            service)    get_service     ;;
            transform)  get_transform   ;;
            paths)      get_paths       ;;
            environ)    get_env         ;;
            config)     get_config      ;;
            *)          echo "$2 is not a recognized command" >&2; exit 2   ;;
        esac
    else
        echo "$1 is not a recognized command"
        exit 2
    fi
fi

case $(echo "${1,,}" | tr -d '[:space:]') in
    transform)  transform           ;;
    clone)      clone_repo          ;;
    release)    release $@          ;;
    *)          echo "$1 is not a recognized commmand"; exit 2  ;;
esac
