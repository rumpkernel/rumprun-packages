#!/bin/sh
set -x
rumprun xen -di -M 128 \
    -I net1,xenif -W net1,inet,static,10.0.120.200/24 \
    -b ../images/data.iso,/data \
    -- ../../nginx/bin/nginx.bin -c /data/conf/nginx.conf
