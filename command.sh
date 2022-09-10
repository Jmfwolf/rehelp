#!/bin/bash
transform() {
    ./preflight "t"
    parallel ::: $TRANSFORM ::: ${PATHS[@]}
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
#Todo: Clone should automatically update the config path
clone_config(){
    ./preflight.sh "c"
    local PRE=$(ls)
    git clone $(yq '.config_repo_url' transform/$TRFILE)
    local POST=$(ls)
    ./command.sh use config $(grep -v -F -x -f $PRE $POST)
    exit 0
}
use_config(){
    CONFIG_PATH=$(echo -e ${1,,} | tr -d '[:space:]')
    yq -i '.config_path = env(CONFIG_PATH)' transforms/$TRFILE
}
use_service(){
    if [[ -z "$1" ]]; then
            ./preflight.sh "s"
        echo "SERVICE has been set to the service value in transform" # This updates in the preflight check, probably not the best way
    else
        SERVICE=$(echo -e ${1,,} | tr -d '[:space:]')
        yq -i '.service = env(SERVICE)' transforms/$TRFILE
        echo $_
    fi
    exit 0
}
get_service(){
    echo "SERVICE: $(yq '.service' transforms/$TRFILE)"
    exit 0
}

get_paths(){
    echo "PATHS=$PATHS"
    exit 0
}

use_paths(){
    PATHS=("$1")
    echo "PATHS has been set to $PATHS.\nDefinitions was not altered"
    ./preflight.sh "p"
    exit 0
}

get_env(){
    echo "ENVIRONMENT: $ENVIRONMENT"
    exit 0
}

use_env(){
    ENVIRONMENT=$(echo -e ${1,,} | tr -d '[:space:]')
    yq -i '.environment = env(ENVIRONMENT)' transforms/$TRFILE
    echo "ENVIRONMENT has been set to $ENVIRONMENT"
    exit 0
}

if [[ ${#1} -lt 4 ]]; then
    if [[ "$1" == "use" ]]; then
        case ${2,,} in
            service)    use_service     $3  ;;
            transform)  use_transform   $3  ;;
            paths)      use_paths       $3  ;;
            environ)    use_env         $3  ;;
            config)     use_config      $3  ;;
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

case $(echo -e ${1,,} | tr -d '[:space:]') in
    transform)  transform           ;;
    clone)      clone_config        ;;
    release)    release $@          ;;
    *)          echo "$1 is not a recognized commmand"; exit 2  ;;
esac
