# rehelp
rehelp is the release helper you never asked for.
Basic assumptions in the software:
- Repositories are on github
- You have cli access to github

## Usage
- `rehelp use $ENV_VAR $VALUETOBESET` will set specified environment variable to the value
- `rehelp get $ENV_VAR` will return the value that is currently stored in the environment variable
- `rehelp transform`    performs the transformation action stored, on the files specified in paths.
- `rehelp clone`         performs a git clone of repo set in config.yml

## Dependencies
software requirements:
- bash
- yq https://github.com/mikefarah/yq
- gnu parallel https://www.gnu.org/software/parallel/

## Quick Start
1. `rehelp use service $SERVICENAME`
2. `rehelp use paths   $PATHS`
3. `rehelp use replace $REPLACEVALUE`
4. `rehelp release`

## Multi Test Execution
The Easiest way to execute multiple service release is `rehelper release -all -y`. THIS IS DANGEROUS if you turn turn off consent it will execute all transform file releases. Only do this if you are sure what the transform code execution is.
## definitions.yml
This file maps the service name to the specific config files that are a part of each service.
Paths configuration is taken by default from this file. It is expected that this file is formatted with each service as an array of paths. [Yaml Arrays](https://www.w3schools.io/file/yaml-arrays/)

This file should also include environment information. It is specifically generic to accomodate different environment management techniques.

## Planned Features
- Automated testing, user provides tests and loads config files for rehelp to execute
- Automated and staggered Pull Requests
- Automated revert of Pull Requests