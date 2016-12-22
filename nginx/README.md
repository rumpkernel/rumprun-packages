Overview
========

Packaging of the [Nginx](http://nginx.org/) 1.8.0 web server for rumprun.

Maintainer
----------

* Martin Lucina, mato@rumpkernel.org
* Github: @mato

Patches
=======

The build process will apply the patches required for cross-compilation
support, which can be found in the `patches/` directory. These patches were
developed by Samuel Martin for the buildroot project, their upstream home is
[here](http://git.buildroot.net/buildroot/tree/package/nginx).

Instructions
============

The build script also requires `genisoimage` in order to build the ISO image
for `/data`.

Run `make`:

```
make
```

Bake the final unikernel image for Xen:
```
rumprun-bake xen_pv bin/nginx.bin bin/nginx
```

or KVM:

```
rumprun-bake hw_generic bin/nginx.bin bin/nginx
```

(Replace `xen_pv`/` hw_generic` with the platform you are baking for.)

Examples on Xen
===============

To start a Xen domU running nginx serving static files, as root run (for
example):

````
rumprun xen -M 128 -di \
    -n inet,static,10.10.10.10/24 \
    -b images/data.iso,/data \
    -- bin/nginx.bin -c /data/conf/nginx.conf
````

Replace `10.10.10.10/24` with a valid IP address on your Xen network.

Examples on KVM
===============

Create a tap device (named tap0) on the host:

````
ip tuntap add tap0 mode tap
ip addr add 10.0.0.10/24 dev tap0
ip link set dev tap0 up
````

Replace `10.0.0.10/24` with a valid IP address that is not used by the host.

To start a unikernel running nginx serving static files, as root run (for
example):

````
rumprun qemu -M 128 -i \
    -I if,vioif,"-net tap,script=no,ifname=tap0" \
    -W if,inet,static,10.0.0.11/24 \
    -b images/data.iso,/data \
    -- bin/nginx.bin -c /data/conf/nginx.conf
````
