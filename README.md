# rehelp
rehelp is the release helper you never asked for.
Basic assumptions in the software:
- Repositories are on github
- You have cli access to github

## Usage
- `rehelp set $ENV_VAR $VALUETOBESET` will set specified environment variable to the value
- `rehelp get $ENV_VAR` will return the value that is currently stored in the environment variable
- `rehelp transform`    performs the transformation action stored, on the files specified in paths.
- `rehelp clone`         performs a git clone of repo set in config.yml

## Dependencies
software requirements:
- bash
- yq https://github.com/mikefarah/yq
- gnu parallel https://www.gnu.org/software/parallel/

## Quick Start
1. `rehelp set service $SERVICENAME`
2. `rehelp set paths   $PATHS`
3. `rehelp set replace $REPLACEVALUE`

## definitions.yml
This file maps the service name to the specific config files that are a part of each service.
Paths configuration is taken by default from this file. It is expected that this file is formatted with each service as an array of paths. [Yaml Arrays](https://www.w3schools.io/file/yaml-arrays/)

This file should also include environment information. It is specifically generic to accomodate different environment management techniques.


