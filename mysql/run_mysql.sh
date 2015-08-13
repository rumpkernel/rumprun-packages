#!/bin/sh
set -x
rumprun xen "$@" -M 128 -i \
    -b images/stubetc.iso,/etc \
    -b images/data.ffs,/data \
    -n inet6,auto \
    -- \
    build/mysql/build-cross/sql/mysqld.bin \
        --defaults-file=/data/my.cnf --basedir=/data --user=daemon
