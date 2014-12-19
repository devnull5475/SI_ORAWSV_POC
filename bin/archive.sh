#!/bin/bash

_format=tar
_name=owsx
_tag=1.0

echo "git archive --format=${_format} --prefix=owsx-${_tag}/ ${_tag} | gzip > ${_name}-${_tag}.tgz"
git archive --format=${_format} --prefix=owsx-${_tag}/ ${_tag} | gzip > ${_name}-${_tag}.tgz
