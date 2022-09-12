#!/bin/bash
transform() {
    ./preflight.sh "t"
    cd .clones/$REPO && git checkout $ENVIRONMENT 
    git checkout -b "$PREFIX-$SERVICE"
    parallel ::: $TRANSFORM ::: ${PATHS[@]}
    echo -e "Enter a commit message:\n"
    read MESS
    git commit -a -m $MESS 
    echo "tranformation complete"
}

use_transform() {
    TRANSFORM=$1
    yq -i '.transform = "$TRANSFORM"' transforms/$TRFILE
    echo "TRANSFORM has been set to $TRANSFORM"
}

get_transform(){
    echo "TRANSFORM: $TRANSFORM"
    exit 0
}

clone_repo(){
    ./preflight.sh "c"
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

release_all(){
    LIST=($(ls transforms/))
    release &
    parallel ::: ./rehelp -t ::: ${LIST[@]} ::: "release --full"
}

release(){
    case ${2,,} in
        --all)       release_all            ;;
        --full)      clone && transform     ;;
    esac
    git push $REPO_URL "$PREFIX-$SERVICE"
    git request-pull $ENVIRONMENT $REPO_URL
}

clean(){
    rm -rf .clones/*
}

case "${1,,}" in
    transform)  transform           ;;
    clone)      clone_repo          ;;
    clean)      clean               ;;
    release)    release             ;;
esac
