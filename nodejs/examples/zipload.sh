#!/bin/bash
make bootstrap.js 1>&2
echo -n 'var zipfile="'
base64 -w 0
echo '";'
echo "var main='$1';"
cat bootstrap.js
