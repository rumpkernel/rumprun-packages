Overview
========

Packaging of unmodified [mathopd](http://mathopd.org/) 1.6b15 for rumprun.

Mathopd is a simple, non-forking HTTP/1.1 compliant webserver, and serves as an
example of how a simple POSIX application can be cross-compiled, unmodified,
for rumprun.

Patches
=======

None required.

Instructions
============

The build script also requires `genisoimage` in order to build the ISO images
for `/data` and `/etc`.

Run `make`:

```
make
```

Bake the final unikernel image:
```
rumpbake xen_pv bin/mathopd.bin bin/mathopd
```

(Replace `xen_pv` with the platform you are baking for.)

Examples
========

To start a Xen domU running mathopd, as root run (for example):

````
rumprun xen -M 32 -di \
    -n inet,static,10.10.10.10/24 \
    -b images/stubetc.iso,/etc \
    -b images/data.iso,/data \
    -- bin/mathopd.bin -n -t -f /data/mathopd.conf
````

Replace `10.10.10.10/24` with a valid IP address on your Xen network.
