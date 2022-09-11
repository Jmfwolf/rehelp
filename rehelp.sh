#!/bin/bash
##
##
##
#
#
## config_path is the target document to be changed
## changes are defined by the yamls provided
#
#
#
if [[ $(id -u) -eq 0 ]]; then
    echo "Do not run as root, that is dangerous." >&2
    exit 4
fi
export TRFILE="default.yml"
export SERVICE=""
export ENVIRONMENT=""
export REPO=""
export PATHS=()
export REPLACE=""
export TRANSFORM=""

__HELP="
rehelp is the release helper you didn't ask for. Automating changes to files through definitions is not limited to pull requests.
rehelp is intended to be flexible enough to allow automating software development. It allows for the automation of file changes and automation of pull requests on those repositories
Usage rehelp [ clone | release | release --all | transform | use <VAR_NAME> <NEW_VALUE> | get <VAR_NAME> ]
    Commands
        - use               Alters inplace the contents of yaml files in transforms directory
        - get               Prints to the command line the value of the variable
        - transform         Creates a branch and performs the indicated operations on the files in the specified repo
        - release           This create pull requests for the repo specified
        - help, -h          Display this message

    Variables in default.yml
        - service: string       defined in definitions.yml
        - environment: string   defined in definitions.yml
        - repo_url: string      url for github.com repo that a git clone can be performed
        - repo_path: string     full path to the folder that changes need to be made in
        - paths: array          defined in default.yml or template as the relative location in the repo of files to be edited
        - transform: string     the instruction(s) for how the files will be modified
        - replace: string       if the transform includes replacing text those can be stored and referenced
"



case $(echo "${1,,}" | tr -d '[:space:]') in
    use)        ./command.sh $@  ;;
    get)        ./command.sh $@  ;;
    clone)      ./command.sh $@  ;;
    transform)  ./command.sh $@  ;;
    help)       echo "$__HELP"   ;;
    --help)     echo "$__HELP"   ;;
    -h)         echo "$__HELP"   ;;  
    *)      echo -e "\n$1 is not a recognized command try \"rehelp -h\"" >&2
esac

