#!/bin/bash
# Use git bisect to find the commit that introduced a bug.
# Info:
#  http://java.dzone.com/articles/automated-bug-finding-git

_USAGE="$0 -b BAD -g GOOD [-t one.failing.Test]" ;

_BAD=HEAD;
_GOOD=1.0;
_VERBOSE=;
_SINGLE_TEST=;

OPTIND=1;
while getopts "b:g:t:vh" opt; do
    case "${opt}" in
        h|\?)
            echo "${_USAGE}" && exit 0 ; ;;
        v)
            _VERBOSE="-v" ; ;;
        b)
            _BAD="${OPTARG}" ; ;;
        g)
            _GOOD="${OPTARG}" ; ;;
        t)
            _SINGLE_TEST="${OPTARG}" ; ;;
    esac
done

[[ -z "${_BAD}" ]] && echo "Missing BAD.\n${_USAGE}" && exit 1 ;
[[ -z "${_GOOD}" ]] && echo "Missing GOOD.\n${_USAGE}" && exit 1 ;

[[ -n "${_VERBOSE}" ]] && echo "git bisect \$_BAD=${_BAD} \$_GOOD=${_GOOD} ./bin/test.sh -t\"${_SINGLE_TEST}\" ${_VERBOSE}"

#git bisect reset
#git bisect start
#git bisect bad "${_BAD}"
#git bisect good "${_GOOD}"
#git bisect run ./bin/test.sh -t "${_SINGLE_TEST} ${_VERBOSE}"
. ./bin/test.sh -t "${_SINGLE_TEST}" "${_VERBOSE}"
