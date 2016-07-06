Overview
========

This is the memcached 1.4.28 package for rumprun unikernels

Maintainer
----------

* Ryan Day, rday@rumpkernel.org
* Github: @rday


Patches
=======

A patch has been made to the configuration file to determine target endianness 
using a command line flag.

A patch has been made to the libevent version check in memcached.c to prevent
a compilation failure due to an error.

Instructions
============

Run `make` from the package directory:

```
cd rumprun-packages/memcached
make
```

This example uses QEMU/KVM and "tap" networking. Depending on your QEMU network
setup, you may need to configure the `tap0` interface manually after the
unikernel has started.

````
rumprun-bake hw_generic build/memcached.bin build/memcached
rumprun kvm -i -M 256 \
    -I if,vioif,'-net tap,script=no,ifname=tap0' \
    -W if,inet,static,10.0.120.101/24 \
    -- build/memcached.bin -u root
````

Test out your memcached server. You should be able to reproduce
a session similar to the following

```
$ telnet 10.0.120.101 11211

set test 0 0 6
onetwo
STORED
get test
VALUE test 0 6
onetwo
END

nc 10.0.120.101 11211
set test 0 0 6
onetwo

set value 0 0 1
1
STORED
incr value 10
11
get value
VALUE value 0 2
11
END
```
