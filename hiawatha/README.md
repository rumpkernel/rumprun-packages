Overview
========

Packaging of [Hiawatha webserver](https:/www.hiawatha-webserver.org/)
version 9.13 for rumprun.

Hiawatha is a lightweight, threaded webserver which is well-suited to running
as a unikernel. It also serves as an example for cross-compiling an application
which uses CMake as its build system.

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
rumpbake hw_virtio bin/hiawatha.bin bin/hiawatha
```

(Replace `hw_virtio` with the platform you are baking for.)

Examples
========

This example uses QEMU/KVM and "tap" networking. Depending on your QEMU network
setup, you may need to configure the `tap0` interface manually after the
unikernel has started.

````
rumprun kvm -i -M 128 \
    -I qnet0,vioif,"-net tap" \
    -W qnet0,inet,static,172.16.0.10/24 \
    -b images/data.iso,/data \
    -- bin/hiawatha.bin -d -c /data/conf
````
