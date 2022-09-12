#!/bin/bash
transform() {
    ./preflight.sh "t"
    ./preflight.sh "e"
    (./command.sh clone) || echo "no clone "
    PREFIX="$( yq '.release_prefix' transforms/$TRFILE )$SERVICE"
    cd .clones/$REPO
    git checkout $ENVIRONMENT && echo "$ENVIRONMENT branch of $REPO"
    git checkout -b $PREFIX
    #echo ".clones/${PATHS[@]}"
    parallel ::: $TRANSFORM ::: ${PATHS[@]}
}
use_transform() {
    TRANSFORM=$1
    yq -i '.transform = env(TRANSFORM)' transforms/$TRFILE
    echo "TRANSFORM has been set to $TRANSFORM"
}
get_transform(){
    echo "TRANSFORM: $TRANSFORM"
    exit 0
}

#Todo: Clone should automatically update the config path
clone_repo(){
    if [[ $(./preflight.sh "c") ]]; then
        exit 0
    fi
    local TEMP=$(yq '.repo_url' transforms/$TRFILE)
    (cd .clones && git clone $TEMP)
    REPO="$(basename $TEMP)"
    exit 0
}

use_repo(){
    local REPO_URL=$(echo -e ${1,,} | tr -d '[:space:]')
    if [[ -z $REPO_URL ]]; then
        echo "Please use a valid path to the repo"
        exit 1
    else
    yq -i '.repo_url = env(REPO_URL)' transforms/$TRFILE
    REPO="$(basename $REPO_URL)"
    fi
    exit 0
}

use_service(){
    if [[ -z "$1" ]]; then
            ./preflight.sh "s"
        echo "SERVICE has been set to the service value in default.yml" # This updates in the preflight check, probably not the best way
    else
        SERVICE=$(echo -e ${1,,} | tr -d '[:space:]')
        yq -i '.service = env(SERVICE)' transforms/$TRFILE
        echo "SERVICE has been set to $SERVICE"
    fi
    exit 0
}
get_service(){
    echo "SERVICE: $(yq '.service' transforms/$TRFILE)"
    exit 0
}

get_paths(){
    echo "PATHS: $PATHS"
    exit 0
}

get_env(){
    echo "ENVIRONMENT: $(yq '.environment' transforms/$TRFILE)"
    exit 0
}

use_env(){
    ENVIRONMENT=$(echo -e ${1,,} | tr -d '[:space:]')
    yq -i '.environment = env(ENVIRONMENT)' transforms/$TRFILE
    echo "ENVIRONMENT has been set to $ENVIRONMENT"
    exit 0
}

release(){
    echo -e "Enter a commit message:\n"
    read MESS
    git commit -a -m '$MESS'
}

case "${1,,}" in
    transform)  transform           ;;
    clone)      clone_repo          ;;
    release)    release             ;;
esac


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


