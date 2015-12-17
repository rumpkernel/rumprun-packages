Overview
========

This packages [HAProxy](http://www.haproxy.org/) 1.6.2 the reliable, High Performance TCP/HTTP Load Balancer.

Maintainer
----------

* Matthias Sperl, Github: m-sp

Instructions
============

Run `make` to build the binary

Either run `make bake_hw_generic` or run `rumprun-bake` on the resulting binary in `build/haproxy`.

Examples
========

For a simple demo execute `make run`. This will start our baked image on qemu.
Open [http://localhost:8080/] in a browser and you should see the statistics page of HAProxy.
