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

    local __usage; __usage="
        $(COLOR_STRING "Purpose:" "cyan" "bold" "true")
            PURPOSE_DESCRIPTION
        
        $(COLOR_STRING "Options:" "cyan" "bold" "true")
            --LONG_PARAMETER_NAME|-SHORT_PARAMETER_NAME:        [REQUIRED] [STRING] - PARAMETER_EXPLANATION.

        $(COLOR_STRING "Switches:" "cyan" "bold" "true")
            --help|-h:                                          [OPTIONAL] - Outputs this help section.

        $(COLOR_STRING "Notes:" "orange" "true")
            > In the examples in the Usage: section below. Add \$? between \"\" to get the exit code of the script and to avoid the parent Bash shell from
            exiting if the exit code is non-zero.

        $(COLOR_STRING "Usage:" "cyan" "bold noprefix" "true")
            [1]: (FUNCTION_NAME --PARAMETER=""INPUT"") && echo \"\$?\" || echo \"\$?\"
            >> EXAMPLE_EXPLANATION.
            ======================= || =======================
    "

    while [ $# -gt 0 ]; do
        case "$1" in
        --clustername*|-cname*)
            if [[ "$1" != *=* ]]; then badArg "$1=${2#*=}"; shift; fi
            local __clustername="${1#*=}"
            ;;
        --example2*|-e2*)
            if [[ "$1" != *=* ]]; then badArg "$1=${2#*=}"; shift; fi
            local __SOME_OTHER_VAR="${1#*=}"
            declare -a __allowedTypes=(
                "type1"
                "type2"
            )
            if [[ ! "${__allowedTypes[*]}" =~ $__SOME_OTHER_VAR ]]; then
                COLOR_STRING "ERROR: An unsupported value was provided to the [--|-] parameter" "ERROR" "bold"
                COLOR_STRING "Valid values are: [type1] or [type2]" "ok" "noprefix"
                exit 6
            fi
            ;;
        --help|-h)
            echo -e "$__usage"
            local __helpUsed="true"
            ;;
        *)
            >&2 printf "Error: Invalid argument\n"
            exit 6
            ;;
        esac
        shift
    done

    if [[ -z "$__helpUsed" ]]; then
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
    fi # End of conditional on the __helpUsed variable
}