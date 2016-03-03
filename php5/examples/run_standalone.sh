#!/bin/sh
set -x
rumprun xen -di -M 128 \
    -I net1,xenif -W net1,inet,static,10.0.120.201/24 \
    -b ../images/data.iso,/data \
    -- ../bin/php.bin -S 0.0.0.0:80 -t /data/www
