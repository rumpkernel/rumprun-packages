#!/bin/sh
# Generate a random string suitable for use as a session key or password.

if [ $# -ne 1 ]; then
    echo usage: $0 LENGTH
    exit 1
fi

LENGTH=$1
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-${LENGTH}};echo;
