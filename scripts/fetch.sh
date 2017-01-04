#!/bin/sh

# This is just a frontend to download upstream source code using wget, curl, or
# other means. The intent is that it can be extended to support git:// URLs and
# verifying checksums.

die()
{
    echo "error: Download of ${URL} failed."
    [ -f ${TARGET} ] && rm -f ${TARGET}
    exit 1
}

if [ $# -ne 2 ]; then
    echo "usage: fetch.sh URL TARGET" 1>&2
    echo "Downloads URL to the TARGET file, using wget or curl." 1>&2
    exit 1
fi
URL=$1
TARGET=$2

if type wget >/dev/null 2>&1; then
    wget ${URL} -O ${TARGET} || die
elif type curl >/dev/null 2>&1; then
    curl -L -o ${TARGET} ${URL} || die
else
    echo "error: Need curl or wget to download ${URL}" 1>&2
    exit 1
fi
