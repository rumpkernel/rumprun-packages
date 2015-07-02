Overview
========

Packaging of unmodified [PHP](http://php.net/) for rumprun.

Download
========

Upstream source will be downloaded by the build process.

Patches
=======

None required.

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
rumpbake xen_pv bin/php-cgi.bin bin/php-cgi
```

(Replace `xen_pv` with the platform you are baking for.)

Examples
========

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
4. As root on your Xen dom0, run `./run_nginx.sh` in one window and
   `./run_php.sh` in another.
5. Browse to `http://<nginx_ip>/`.
