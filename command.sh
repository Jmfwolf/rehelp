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

<<<<<<< Updated upstream
release(){
    case ${2,,} in
        --all)       FILLER      ;;
        --full)      clone && transform     ;;
    esac

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
=======
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
>>>>>>> Stashed changes
esac
