Overview
========

Packaging of unmodified [Nginx](http://nginx.org/) for rumprun.

Download
========

Upstream source will be downloaded by the build process.

Patches
=======

The build process will apply the patches required for cross-compilation
support, which can be found in the `patches/` directory. These patches were
developed by Samuel Martin for the buildroot project, their upstream home is
[here](http://git.buildroot.net/buildroot/tree/package/nginx).

Instructions
============

The build script also requires `genisoimage` in order to build the ISO images
for `/data` and `/etc`.

Run `make`, setting `CC` to target architecture cross-compiler, e.g.

```
make CC=x86_64-rumprun-netbsd-cc
```

Bake the final unikernel image:
```
rumpbake xen_pv bin/nginx.bin bin/nginx
```

(Replace `xen_pv` with the platform you are baking for.)

Examples
========

To start a Xen domU running nginx serving static files, as root run (for
example):

````
rumprun xen -M 128 -di \
    -n inet,static,10.10.10.10/24 \
    -b images/stubetc.iso,/etc \
    -b images/data.iso,/data \
    -- bin/nginx.bin -c /data/conf/nginx.conf
````

Replace `10.10.10.10/24` with a valid IP address on your Xen network.
