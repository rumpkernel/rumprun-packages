Overview
========

Packaging of the [Tor](http://torproject.org/) 0.2.7.6 tor server.

Maintainer
==========

* Kyle Amon, amonk@backwatcher.com [GPG: ed25519/F57091DBD60FBBB8]
* Freenode: amonk [OTR: DC446975 0D1CC62D 092E633C 2E3D3D82 B4CE1C47]
* Github: @supradix

Instructions
============

Run `make`:

```
make
```

The Makefile utilizes genext2fs to automagically prepare a writable disk
image with the contents of the `image` directory.  In the `image/conf`
directory, there are several torrc files: torrc, torrc.relay and torrc.exit.
If you do nothing, the default torrc file is identical to torrc.relay,
providing a minimal relay only configuration.  If you would prefer to run
an exit node, copy torrc.exit to torrc for a minimal exit configuration
instead.  Modify these example configuration files as you see fit.

Build the file system image:

```
make image
```

Bake the final tor unikernel image.  For example:
```
rumprun-bake hw_virtio tor.bin build/src/or/tor
```

Examples
========

Before running the tor unikernel in userland, you must configure some
networking support.  On Linux, for example, run commands such as the
following:

````
ip tuntap add tap0 mode tap
ip addr add 10.10.10.1/24 dev tap0
ip link set dev tap0 up

iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 10.10.10.10
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.10.10.10
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "1" > /proc/sys/net/ipv4/ip_forward
````

To then run the tor unikernel with qemu via rumprun, execute a command
such as the following:

````
rumprun qemu -i -M 256 -N rumptor \
  -I tap0,vioif,'-net tap,script=no,ifname=tap0' \
  -W tap0,inet,static,10.10.10.10/24,10.10.10.1 \
  -b tor.img,/tor \
  -- tor.bin -f /tor/conf/torrc
````

To instead run the tor unikernel via qemu directly, execute a command
such as the following:

````
qemu-system-x86_64 -m 256 -no-kvm \
  -nographic -display curses -monitor stdio \
  -drive index=0,if=virtio,file=tor.img \
  -net nic,model=virtio,macaddr=00:13:37:00:00:01 \
  -net tap,script=no,ifname=tap0 \
  -kernel tor.bin \
  -append '{,, "blk" : {,, "source": "dev",, "path" : "/dev/ld0a",, "fstype": "blk",, "mountpoint": "/tor",, },, "net" :  {,, "if": "vioif0",, "type": "inet",, "method": "static",, "addr" : "10.10.10.10",, "mask" : "24",, "gw": "10.10.10.1",, },, "cmdline": "tor.bin -f /tor/conf/torrc ",, },,'


````

Note
========

This has only been tested with qemu on Linux.  Adjustments will need to
be made for other environments.
