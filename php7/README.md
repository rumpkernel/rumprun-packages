Overview
========

Packaging of unmodified [PHP](http://php.net/) 7.0.3 for rumprun.

Maintainer
----------

* Martin Lucina, mato@rumpkernel.org
* Github: @mato

* Brian Graham, drakain@github.com
* Github: @incognito

Patches
=======

None required.

Instructions
============

The build script also requires `genisoimage` in order to build the ISO image
for `/data`.

Run `make`:

```
make
```

Bake the final unikernel images:
```
rumprun-bake xen_pv bin/php-cgi.bin bin/php-cgi
rumprun-bake xen_pv bin/phpi.bin bin/php
```

(Replace `xen_pv` with the platform you are baking for.)

Examples
========

Running a standalone PHP unikernel
----------------------------------

PHP includes a built-in webserver for development and testing. You can use this
to run a standalone PHP unikernel with no need for Nginx.


```
rumprun xen -di -M 128 \
    -I net1,xenif -W net1,inet,static,10.0.120.201/24 \
    -b ../images/data.iso,/data \
    -- ../bin/php.bin -S 0.0.0.0:80 -t /data/www
```

Note that this is *not* intended for production use, for that you will want a
setup using FastCGI.
