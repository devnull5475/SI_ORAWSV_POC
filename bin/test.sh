#!/bin/bash

mvn clean test
rc=$?
if [[ $rc != 0 ]] ; then
    return 1 ;
else
    return 0 ;
fi
