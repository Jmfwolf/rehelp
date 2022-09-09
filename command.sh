#!/bin/bash

if [[ "$1"]]


transform() {
    parallel ::: $TRANSFORM ::: ${PATHS[@]}
}
set_transform() {
    TRANSFORM=$1
}

pull_config(){
    git clone $(yq '.config_repo_url' ../yml/config)
    echo "Update your config path\n rehelp set paths PATH"
}

set_service(){
    yq -i '.service = "$1' ../yml/transform.yml
}
get_service(){
    echo $SERVICE
}

get_paths(){
    echo $PATHS
}

set_paths(){
    PATHS=$1
}