Overview
========

The following instructions will build the leveldb v1.18 key-value database
and run its benchmark under the _hw_ platform. It should work on Xen as
well but it is not tested yet.

###Maintainer

* Krishna, v.krishnakumar@gmail.com
* Github: @kaveman-
* #rumpkernel: kaveman

Patches
=======

Patches for cross-compilation are found inside the patches/ directory and are
applied as part of the build process.

Instructions
============

Run make:

```
make
```

That should build the static library and a bunch of tests along with a
benchmark. By default, these are installed in bin/. The static library and
headers are installed to lib/ and include/ respectivey. To change the
installation directory, adjust INSTALL_PREFIX in the Makefile.

Run `rumprun-bake` on the desired test and the benchmark programs. You will most
likely want to use the `hw_generic` target, e.g `rumprun-bake hw_generic
bin/db_bench.bin bin/db_bench`.

Examples
========

First, create a filesystem for the block device that will hold the temporary
databases.

```
mkfs.ext2 data.img 512M
```

and then run...

```
rumprun qemu -i -M 512 -b data.img,/data -e TEST_TMPDIR=/data bin/db_bench.bin
```

or a test...

```
rumprun qemu -i -M 512 -b data.img,/data -e TEST_TMPDIR=/data bin/corruption_test.bin
```

Todo
====

- support for compression using snappy
