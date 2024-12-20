#!/bin/bash
# shellcheck disable=SC1091
: <<'#'
    N.B. on the disabled shellchecks
        > SC1091. We do not need it as the sourced functions will be shellchecked
            when they are changed anyways. And shellcheck do not support dynamic/relative paths.
#
FUNCTION_NAME()
{
    set -eo pipefail
    shopt -s inherit_errexit

    local __gitRootFolder; __gitRootFolder="$(git rev-parse --show-toplevel)"
    local __rootFolder; __rootFolder="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd)"
    local __srcFolder; __srcFolder="$__gitRootFolder/src/bash"
    source "$__srcFolder/badArg"
    source "$__srcFolder/colors"

    if [ -t 1 ] || [[ $- == *i* ]]; then
        local __interactive; __interactive="true"
    fi

    local __usage; __usage="
        $(COLOR_STRING "Purpose:" "cyan" "bold" "${__interactive}")
            PURPOSE_DESCRIPTION
        
        $(COLOR_STRING "Options:" "cyan" "bold" "${__interactive}")
            --LONG_PARAMETER_NAME|-SHORT_PARAMETER_NAME:        [REQUIRED] [STRING] - PARAMETER_EXPLANATION.

        $(COLOR_STRING "Switches:" "cyan" "bold" "${__interactive}")
            --help|-h:                                          [OPTIONAL] - Outputs this help section.

        $(COLOR_STRING "Notes:" "orange" "${__interactive}")
            > In the examples in the Usage: section below. Add \$? between \"\" to get the exit code of the script and to avoid the parent Bash shell from
            exiting if the exit code is non-zero.

        $(COLOR_STRING "Usage:" "cyan" "bold noprefix" "${__interactive}")
            [1]: (FUNCTION_NAME --PARAMETER=""INPUT"") && echo \"\$?\" || echo \"\$?\"
            >> EXAMPLE_EXPLANATION.
            ======================= || =======================
    "

    ##
    # Initialize required variables
    # to avoid scope creep. Where
    # variables declared with the same name
    # in X calling func. is available here.
    ##
    local __clustername; __clustername=""
    local __myOtherRequiredVar; __myOtherRequiredVar=""

    while [ $# -gt 0 ]; do
        case "$1" in
        --clustername*|-cname*)
            if [[ "$1" != *=* ]]; then badArg "$1=${2#*=}"; shift; fi
            local __clustername="${1#*=}"
            ;;
        --example2*|-e2*)
            if [[ "$1" != *=* ]]; then badArg "$1=${2#*=}"; shift; fi
            local __VARIABLE_NAME="${1#*=}"
            case $__VARIABLE_NAME in
                option1|option2|....);;
                *)
                COLOR_STRING "An unsupported value was provided to the [--example2|-e2] parameter" "ERROR" "BOLD"
                COLOR_STRING "Valid values are: [option1], [option2] or [....]" "ok" "noprefix" >&2
                exit 6
                ;;
            esac
            ;;
        --help|-h)
            echo -e "$__usage"
            exit 0
            ;;
        *)
            COLOR_STRING "Invalid argument\n" "ERROR" "BOLD"
            exit 6
            ;;
        esac
        shift
    done

    source "$__srcFolder/trapErr"
    source "$__srcFolder/validateClusterName"
    source "$__srcFolder/validatePreReqs"
    source "$__srcFolder/verifyK8sContext"

    # The below functions called in the order
    # of the least compute expensive.
    validateClusterName "${__clustername}"
    validatePreReqs "CMD_NAME"
    verifyK8sContext --clustername="${__clustername}"

    ###########
    # EXECUTE #
    ###########
    local __SOME_ARG_NAME="{$__clustername}"
    
    # EXPLAIN_WHAT_IS_BEING_DONE
    #local __result=$()

    #echo "$__result"
}
