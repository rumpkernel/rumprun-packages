Overview
========

Packaging of the [Apache](https://httpd.apache.org/) 2.4.20 http server for rumprun.

Maintainer
----------

* Myungho Jung, mhjungk@gmail.com
* Github: @myunghoj

Patches
=======

Apache httpd and APR have a bug when cross compiling [here](https://bz.apache.org/bugzilla/show_bug.cgi?id=51257). This patch avoids compiling `gen_test_char` with not rumprun but host compiler.

Instructions
============

`Makefile` will automatically download sources as tar, extract, apply patches, and build them.

```
make
```

Basically, Dynamic Shared Object(DSO) is disabled because Rumprun doesn't support shared library.

And bake the image like below:

```
rumprun-bake hw_virtio bin/httpd.bin bin/httpd
```

Replace the platfrom with yours.

Examples
========

To run a Apache httpd server on qemu, first add a tap device on network.

````
sudo ip tuntap add tap0 mode tap
sudo ip addr add 10.0.120.100/24 dev tap0
sudo ip link set dev tap0 up
````

And, run the next command to start Apache http daemon on rump kernel.

````
rumprun qemu -i -M 512 \
    -I qnet0,vioif,'-net tap,script=no,ifname=tap0' \
    -W qnet0,inet,static,10.0.120.101/24 \
    -b ../images/data.iso,/data \
    -- ../bin/httpd.bin -k start -DONE_PROCESS
````

Should change the IP address to your one.

Known issues
============

`mod_unique_id` is disabled by default because `apr_sockaddr_info_get()` in `modules/metadata/mod_unique_id.c` returns error. It seems like address cannot be found by hostname `rumprun`.

Also, `mod_auth_digest` cannot be used for now because of page fault error caused by `mmap` system call.

`-DONE_PROCESS` option should be set when starting. Otherwise, rumprun is halted after forking and finishing parent process.
