Overview
========

Packaging of unmodified [PHP](http://php.net/) 5.6.18 for rumprun.

Maintainer
----------

* Martin Lucina, mato@rumpkernel.org
* Github: @mato

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
setup using FastCGI, see below. The above script is also included as
`examples/run_standalone.sh`.

Running a nginx + PHP demo
--------------------------

(TODO: Someone should write up this example for KVM)

To run a full demo stack consisting of an nginx unikernel talking over FastCGI
to a PHP unikernel:

You will need a working Xen network set up, and two IP addresses for the demo.
One will be used by the Xen domU running the HTTP server, the other by the domU
running PHP serving FastCGI.

1. Build the nginx unikernel (packaged as ../nginx).
2. Edit `examples/run_nginx.sh` and `examples/run_php.sh`, replacing the IP
   addresses used as appropriate.
3. Edit `images/data/conf/nginx.conf` replacing the IP address in
   `fastcgi_pass` to match the IP you will use for the PHP domU.
4. Rebuild the `data.img` file (run `make`).
5. As root on your Xen dom0, run `./run_nginx.sh` in one window and
   `./run_php.sh` in another.
6. Browse to `http://<nginx_ip>/`.
