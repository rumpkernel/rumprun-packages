#!/bin/sh
#
# Script to trigger a Travis build, suitable for running from cron.
#
# Run as: TRAVIS_TOKEN=xxxxxx /path/to/script rumpkernel/rumprun-packages
#
# You can obtain TRAVIS_TOKEN by installing the Travis CLI and running:
#
# $ travis login
# $ travis token
#
set -x

if [ -z "${TRAVIS_TOKEN}" ]; then
    echo Error: Set TRAVIS_TOKEN before calling this script 1>&2
    exit 1
fi

if [ $# -lt 1 ]; then
    echo Error: Usage: $0 REPOSITORY [BRANCH] 1>&2
    exit 1
fi
REPOSITORY=$(echo $1 | sed -e 's!/!%2f!g')
shift
BRANCH=${1:-master}

body=$(cat <<EOM
{
"request": {
  "branch":"${BRANCH}",
  "message":"Scheduled build via API"
}}
EOM
)

curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token ${TRAVIS_TOKEN}" \
  -d "${body}" \
  https://api.travis-ci.org/repo/${REPOSITORY}/requests

