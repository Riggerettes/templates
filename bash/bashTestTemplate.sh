#!/bin/bash
# shellcheck disable=SC1091
: <<'#'
    N.B. on the disabled shellchecks
        > SC1091. We do not need it as the sourced functions will be shellchecked
            when they are changed anyways. And shellcheck do not support dynamic/relative paths.
#
TEST_FUNCTION_NAME()
{
    set -eo pipefail
    shopt -s inherit_errexit
    
    local __gitRootFolder; __gitRootFolder="$(git rev-parse --show-toplevel)"
    local __srcFolder; __srcFolder="$__gitRootFolder/src/bash"
    source "$__srcFolder/trapErr"
    source "$__srcFolder/validateClusterName"
    source "$__srcFolder/validatePreReqs"
    source "$__srcFolder/verifyK8sContext"

    validateClusterName "${__clustername}"
    validatePreReqs "CMD_NAME"
    verifyK8sContext "${__clustername}"

    ###########
    # EXECUTE #
    ###########
    local __SOME_ARG_NAME=""
}

shunit2Path="$(realpath ~/shunit2)"
if [[ ! -d "$shunit2Path" ]]; then
    echo -e "\n$(tput setaf 1)$(tput bold) #### shunit2 is not installed into ~/ $(tput init)"
    echo -e "\n$(tput setaf 1)$(tput bold) #### Install shunit2 into your homepath and try again. $(tput init)"
fi

# Load shUnit2.
. "$shunit2Path/shunit2"