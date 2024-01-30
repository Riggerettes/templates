#!/bin/bash
# shellcheck disable=SC1091
: <<'#'
    N.B. on the disabled shellchecks
        > SC1091. We do not need it as the sourced functions will be shellchecked
            when they are changed anyways. And shellcheck do not support dynamic/relative paths.
#
set -eo pipefail
shopt -s inherit_errexit

gitRootFolder="$(git rev-parse --show-toplevel)"
rootFolder="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd)"
srcFolder="$gitRootFolder/src/bash"
source "$srcFolder/badArg"
source "$srcFolder/colors"

usage="
    $(COLOR_STRING "Purpose:" "cyan" "bold")
        PURPOSE_DESCRIPTION
    
    $(COLOR_STRING "Options:" "cyan" "bold")
        --LONG_PARAMETER_NAME|-SHORT_PARAMETER_NAME:       [REQUIRED] [STRING] - PARAMETER_EXPLANATION.

    $(COLOR_STRING "Switches:" "cyan" "bold")
        --help|-h:                   [OPTIONAL] - Outputs this help section.

    $(COLOR_STRING "Notes:" "orange")
        > In the examples in the Usage: section below. Add \$? between \"\" to get the exit code of the script and to avoid the parent Bash shell from
        exiting if the exit code is non-zero.

    $(COLOR_STRING "Usage:" "cyan" "bold noprefix")
        [1]: (SCRIPT_NAME --PARAMETER=""INPUT"") && echo \"\$?\" || echo \"\$?\"
        >> EXAMPLE_EXPLANATION.
        ======================= || =======================
"

while [ $# -gt 0 ]; do
    case "$1" in
    --clustername*|-cname*)
        if [[ "$1" != *=* ]]; then badArg "$1=${2#*=}"; shift; fi
        clustername="${1#*=}"
        ;;
    --example2*|-e2*)
        if [[ "$1" != *=* ]]; then badArg "$1=${2#*=}"; shift; fi
        SOME_OTHER_VAR="${1#*=}"
        declare -a __allowedTypes=(
            "type1"
            "type2"
        )
        if [[ ! "${__allowedTypes[*]}" =~ $SOME_OTHER_VAR ]]; then
            COLOR_STRING "ERROR: An unsupported value was provided to the [--|-] parameter" "ERROR" "bold"
            COLOR_STRING "Valid values are: [type1] or [type2]" "ok" "noprefix"
            exit 6
        fi
        ;;
    --help|-h)
        echo -e "$usage"
        helpUsed="true"
        ;;
    *)
        >&2 printf "Error: Invalid argument\n"
        exit 6
        ;;
    esac
    shift
done

if [[ -z "$helpUsed" ]]; then
    source "$srcFolder/trapErr"
    source "$srcFolder/validateClusterName"
    source "$srcFolder/validatePreReqs"
    source "$srcFolder/verifyK8sContext"

    # The below functions called in the order
    # of the least compute expensive first.
    validateClusterName "${clustername}"
    validatePreReqs "CMD_NAME"
    verifyK8sContext --clustername="${clustername}"

    ###########
    # EXECUTE #
    ###########
    echo "{$rootFolder}"
    
    # EXPLAIN_WHAT_IS_BEING_DONE
    #local __result=$()

    #echo "$__result"
fi # End of conditional on the __helpUsed variable