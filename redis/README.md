Overview
========

Packaging of [Redis key-value cache](http://redis.io) version 3.0.2
for rumprun.

Redis is an open source, BSD licensed, advanced key-value cache
and store. It is often referred to as a data structure server
since keys can contain strings, hashes, lists, sets, sorted sets,
bitmaps and hyperloglogs.

Known Issues
------------

- Data persistence is disabled in the config as redis forks to snapshot data.

Patches
=======

None required.

Instructions
============

The build script also requires `genisoimage` in order to build the ISO image
for `/data` and `/etc`.

To build, just run `make`.

```
make
```

Bake the final unikernel image:
```
rumpbake hw_generic bin/redis-server.bin bin/redis-server
```

(Replace `hw_generic` with the platform you are baking for.)

Examples
========

This example uses QEMU/KVM and "tap" networking. Depending on your QEMU network
setup, you may need to configure the `tap0` interface manually after the
unikernel has started.

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
