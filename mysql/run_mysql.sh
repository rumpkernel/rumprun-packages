#!/bin/sh
set -x
rumprun xen "$@" -M 128 -i \
    -b images/data.ffs,/data \
    -n inet6,auto \
    -- \
    bin/mysqld.bin \
        --defaults-file=/data/my.cnf --basedir=/data --user=daemon
