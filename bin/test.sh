#!/bin/bash

_USAGE="$0 [-t org.our_firm.our_app.TestNewBug]";
_SINGLE_TEST=;

OPTIND=1;
while getopts "t:vh" opt; do
    case "${opt}" in
        h|\?)
            echo "${_USAGE}" && exit 0 ; ;;
        v)
            _VERBOSE=1 ; ;;
        t)
            _SINGLE_TEST="${OPTARG}" ; ;;
    esac
done

[[ -n "${_VERBOSE}" ]] && echo "\$_SINGLE_TEST=${_SINGLE_TEST}" ;

if [[ -z "${_SINGLE_TEST}" ]] ; then
 mvn clean test ;
else
 mvn clean -Dtest=${_SINGLE_TEST} test ;
fi

rc=$?
if [[ $rc != 0 ]] ; then
    return 1 ;
else
    return 0 ;
fi
