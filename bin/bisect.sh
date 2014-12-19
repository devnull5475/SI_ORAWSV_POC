#!/bin/bash
echo "NB: This won't work of $_BAD or $_GOOD change either this file or test.sh";
_USAGE="$0 -b BAD -g GOOD\nNB: This won't work if \$_BAD or \$_GOOD change either this file or test.sh";

_BAD=HEAD;
_GOOD=1.0;
_VERBOSE=;

OPTIND=1;
while getopts "b:g:vh" opt; do
    case "${opt}" in
        h|\?)
            echo "${_USAGE}" && exit 0 ; ;;
        v)
            _VERBOSE=1 ; ;;
        b)
            _BAD="${opt}" ; ;;
        g)
            _GOOD="${opt}" ; ;;
    esac
done

[[ -z "${_BAD}" ]] && echo "${_USAGE}" && exit 1 ;
[[ -z "${_GOOD}" ]] && echo "${_USAGE}" && exit 1 ;

[[ -n "${_VERBOSE}" ]] && echo "git bisect \$_BAD=${_BAD} \$_GOOD=${_GOOD} ./bin/test.sh"

git bisect reset
git bisect start
git bisect bad "${_BAD}"
git bisect good "${_GOOD}"
git bisect run ./bin/test.sh
