Overview
========

The following instructions will build the leveldb key-value database and run
its benchmark under the _hw_ platform. It should work on Xen as well but it is
not tested yet.


Download
=========

Download and untar the leveldb sources from
https://github.com/google/leveldb/releases/latest

v1.18 is the latest at this time of writing and so we'll be using that.

Patches
=======

patch-crosscompile-? adjusts the build system to generate only static libraries
and build all the tests. 

Instructions
============

```
x86_64-rumprun-netbsd-make TARGET_OS=NetBSD
```

That should build the static library and a bunch of tests along with a
benchmark.

Run `rumpbake` on the desired test and the benchmark programs. You will most
likely want to use the `hw_generic` target, e.g `rumpbake hw_generic
db_bench.bin ./db_bench`.


Examples
========

First, create a filesystem for the block device that will hold the temporary
databases.

```
mkfs.ext2 data.img 512M
```

and then run...

```
rumprun kvm -i -M 512 -b data.img,/data -e TEST_TMPDIR=/data ./db_bench.bin
```

or a test...

```
rumprun kvm -i -M 512 -b data.img,/data -e TEST_TMPDIR=/data ./corruption_test.bin
```
