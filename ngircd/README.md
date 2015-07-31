Overview
========

Packaging of unmodified [ngircd](http://ngircd.barton.de/) 22.1.

ngIRCd is "a free, portable and lightweight Internet Relay Chat server for small
or private networks".

Patches
=======

None required.

Instructions
============

The configuration script needs to be generated so `aclocal` is needed.  
The build script also requires `genisoimage` in order to build the ISO images
for `/data` and `/etc`.

Run `make` to build ngIRCd:
```
make
```

Bake the final unikernel image:
```
rumpbake xen_pv bin/ngircd.bin bin/ngircd
```
(Replace `xen_pv` with the platform you are baking for.)

You may want to edit the example configuration that will be put in
`images/data/conf/` directory after a successful `make` (for example,
to change the server name, to setup the administrative informations that are
required by RFC, to add some default channels, etc).  
Once this is done you can create the ISO images with:
```
make images
```

Examples
========

To start a Xen domU running ngIRCd, as root run (for example):
````
rumprun xen -M 32 -di \
    -n inet,static,10.10.10.10/24 \
    -b images/stubetc.iso,/etc \
    -b images/data.iso,/data \
    -- bin/ngircd.bin --config /data/conf/ngircd.conf --nodaemon
````
The `--nodaemon` option is required to avoid ngIRCd calling `fork()`.  
Replace `10.10.10.10/24` with a valid IP address on your Xen network.

If SSL is needed, ngIRCd is build with OpenSSL support. You can follow a quick
how-to on the [official site](http://ngircd.barton.de/doc/SSL.txt) to known how
to configure ngIRCd for SSL and create a self-signed certificate.
