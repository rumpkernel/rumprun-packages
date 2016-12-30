Overview
========

Packaging of [Redis key-value cache](http://redis.io) version 3.0.6
for rumprun.

Redis is an open source, BSD licensed, advanced key-value cache
and store. It is often referred to as a data structure server
since keys can contain strings, hashes, lists, sets, sorted sets,
bitmaps and hyperloglogs.

###Maintainer

* Krishna, v.krishnakumar@gmail.com
* Github: @kaveman-
* #rumpkernel: kaveman

Known Issues
------------

- RDB Data persistence is disabled in the config as redis forks to snapshot data
- AOF (Append Only File) works for persistence by building redis (*default `make`*)

 **See (http://redis.io/topics/persistence) for an comparison of AOF and RDB persistence mode**


Instructions
============

The build script also requires `genisoimage` in order to build the ISO image
for `/data` and `/backup`

**There are two build options:**
-  `make` builds redis with AOF persistence
-  `make cache` builds redis **without** persistence (e.g. when used as a cache)

**Running redis with AOF persistence decreases performance compared to version without persistence**

Bake the final unikernel image:
```
rumprun-bake <target_platform> bin/redis-server.bin bin/redis-server
```

(Replace `<target_platform>` with the platform you are baking for.)

Examples
========

This example uses QEMU/KVM and "tap" networking. Depending on your QEMU network
setup, you may need to configure the `tap0` interface manually after the
unikernel has started.


Run redis with AOF persistence (build with `make`)
------------------------------------------------------
````
rumprun qemu -i -M 256 \
    -I if,vioif,'-net tap,script=no,ifname=tap0' \
    -W if,inet,static,10.0.120.101/24 \
    -b images/data.iso,/data \
    -b images/datapers.img,/backup \
    -- bin/redis-server.bin /data/conf/redisaof.conf
````

Run Redis without any Persistence (build with `make cache`)
------------------------------------------------------
````
rumprun qemu -i -M 256 \
    -I if,vioif,'-net tap,script=no,ifname=tap0' \
    -W if,inet,static,10.0.120.101/24 \
    -b images/data.iso,/data \
    -- bin/redis-server.bin /data/conf/redis.conf
````


A quick test:

```
$ nc 10.0.120.101 6379
ping
+PONG
set msg "Hello, World!"
+OK
get msg
$13
Hello, World!
^C
$ nc 10.0.120.101 6379
get msg
$13
Hello, World!
```
