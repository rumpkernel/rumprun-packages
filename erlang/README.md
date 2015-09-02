Overview
========

This document will enable you to bake erlang on rumprun and launch
it within qemu, while running in xen falls on the same lines.

Patches
=======

The patches within the `patches/` sub-directory is primarily to get
ssl working, although in future it'll host some optimizations as
discussed in `Unoptimized Memory Allocation`_ subsection.

Instructions
============

Run this `make` from a user account, *not the root account*. At the end of the
installation, the Makefile will build two variants of the build. One is
required for a host, so that the erlang code can be compiled on this
host (.erl) to .beam. There is another one which can be baked for rumprun
kernel.

The build script requires `genisoimage` to create `erlang.iso` image.

Run `make` from the erlang package directory:

```
cd rumprun-packages/erlang
make
```

Examples
========

There are sample erlang applications (echoserver and helloworld) which can
be built via the `make examples`. The details of the build are captured in
the Makefile.

```
make examples
```

Next you'll need a baked image which can be run on qemu (or kvm or xen).

The following build command will generate an image for non-smp, while using
`hw` as the platform.

```
rumpbake hw_virtio beam.hw.bin bin/beam
```

The above can be either used in qemu or kvm. In case you
want to use xen then the following commands can be used towards the same.

> Note that the build commands in turn use *rumpbake* internally, so
> be sure that you have built the appropriate platform for it
> to work. Additionally rumpbake with xen_pv is used in the Makefile.

```
rumpbake xen_pv bin/beam.xen_pv.bin bin/beam
```

Now you've got a baked unikernel image.

Setup the networking as follows (if not done already).

```
sudo ip tuntap add tap0 mode tap
sudo ip addr add 10.0.120.100/24 dev tap0
sudo ip link set dev tap0 up
```

You are now ready to run your first erlang unikernel. To run the rumpkernel using qemu, the following will work:

```
ERLAPP_PATH=/apps/erlang
ERLHOME=/tmp
ERLPATH=/opt/erlang
rumprun qemu \
   -I if,vioif,'-net tap,script=no,ifname=tap0' \
   -W if,inet,static,10.0.120.101/24 \
   -e ERL_INETRC=$ERLPATH/erl_inetrc \
   -b images/erlang.iso,$ERLPATH \
   -b examples/app.iso,$ERLAPP_PATH \
   -i beam.hw.bin \
     "-- -no_epmd -root $ERLPATH/lib/erlang -progname erl -- -home $ERLHOME -noshell -pa $ERLAPP_PATH -s echoserver start"
```

You should see `Echo server started` text printed to your screen.

Now you can connect to the server via telnet as shown below:

```
$ telnet 10.0.120.101 8080
Trying 10.0.120.101...
Connected to 10.0.120.101.
Escape character is '^]'.
GET /
GET /
hello there!
hello there!
^]

telnet> quit
Connection closed.
```

You should replace `qemu` with `kvm` to run under kvm. For xen there will be
equivalent variation and additionally use xen baked unikernel as well.

Customizations
==============

The /opt/erlang
---------------

In case you want to change the /opt/erlang path then
you'll have to change the Makefile, erl_inetrc and all
the manual instructions mentioned in this document.

Notes
=====

DNS
---

At present the erlang configuration inet configuration is tuned
to use file and DNS as a source of resolving ip/host, though untested.

Shortcomings
============

EPMD (clustering)
-----------------

In it's current form the epmd is not integrated within the baked
image, so there is no support for clustering. Having said that it is
not very difficult to hack together an image and get it working, but
this is in the works at the time of this writing.


Unoptimized Memory Allocation
-----------------------------

At present there is an unoptimal allocation of memory as a consequence of
erlang alloc interacting with rumprun. This will be fixed in the near
future, but something to be aware of in case you care. The exact amount
of memory wasted is not quantified, because it needs to be fixed anyways.

Unsupported SMP
---------------

SMP binary though available is useless, since rumprun doesn't support it.

The rumpkernel supports SMP, but since rumprun won't support in the forceable
future, so it wont't work.
