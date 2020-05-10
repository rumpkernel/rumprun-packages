Overview
========

Packaging of the [h2o](http://h2o.examp1e.net/) 2.0.4 HTTP server for rumprun.

Instructions
============

The build script also requires `genisoimage` in order to build the ISO image
for `/data`.

Run `make`:

```
make
```

Bake the final unikernel image:
```
rumprun-bake xen_pv bin/h2o.bin bin/h2o
```

(Replace `xen_pv` with the platform you are baking for.)

Examples
========

To start a Xen domU running h2o serving static files, as root run (for
example):

````
rumprun xen -M 128 -di \
    -n inet,static,10.10.10.10/24 \
    -b images/data.iso,/data \
    -- bin/h2o.bin -c /data/conf/h2o.conf
````

Replace `10.10.10.10/24` with a valid IP address on your Xen network.
