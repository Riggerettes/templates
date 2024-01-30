#!/bin/bash
# shellcheck disable=SC1091
: <<'#'
    N.B. on the disabled shellchecks
        > SC1091. We do not need it as the sourced functions will be shellchecked
            when they are changed anyways. And shellcheck do not support dynamic/relative paths.
#
set -o pipefail # Not using set -e because of: https://github.com/kward/shunit2/issues/174#issuecomment-1916892046
shopt -s inherit_errexit

gitRootFolder="$(git rev-parse --show-toplevel)"
srcFolder="$gitRootFolder/PATH_TO_FOLDER_OF_FUNCTION_TO_TEST"
source "$srcFolder/NAME_OF_FUNCTION_TO_TEST"

testFUNCTION_NAME()
{
    local __result; __result=""
    # YOUR ASSERTION HERE
}

shunit2Path="$(realpath ~/shunit2)"
if [[ ! -d "$shunit2Path" ]]; then
    echo -e "\n$(tput setaf 1)$(tput bold) #### shunit2 is not installed into ~/ $(tput init)"
    echo -e "\n$(tput setaf 1)$(tput bold) #### Install shunit2 into your homepath and try again. $(tput init)"
fi

# Load shUnit2.
. "$shunit2Path/shunit2"