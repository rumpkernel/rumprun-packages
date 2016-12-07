Overview
========

Packaging of the Open vSwitch for rumprun.

Maintainer
----------

* Hui Kang, hkang.sunysb@gmail.com
* Github: @huikang

Instructions
============

Setup the rumprun toolchain in the `PATH` if you have not done so. Run `make`:

```
make
```

The executables and libraries are install at `./build-cross/ovs/`.

Bake the ovs images:

    rumprun-bake hw_generic ./ovsdb-tool.bin ./build-cross/ovs/bin/ovsdb-tool
    rumprun-bake hw_generic ./ovsdb-server.bin ./build-cross/ovs/sbin/ovsdb-server
    rumprun-bake hw_generic ./ovs-vswitchd.bin ./build-cross/ovs/sbin/ovs-vswitchd

Initialize the ovsdb database::

    ./start-ovsdb-tool.sh

The ovsdb-tool unikernel returns immediately because it is used to create an
empty database with ovsdb schema.

Create two tap devices on the host:

````
ip tuntap add tap0 mode tap
ip tuntap add tap1 mode tap
ip link set dev tap0 up
ip link set dev tap1 up
````

Create a bridge named ``br0`` and attach tap0 and  tap1 to ``br0``:

````
brctl addbr br0
ip addr add 10.0.0.10/24 dev br0
ip link set br0 up
brctl addif br0 tap0
brctl addif br0 tap1
````

Start the ovsdb server unikernel VM:

    ./start-ovsdb-server.sh

Start the ovs-vswitchd unikernel VM:

    ./start-ovs-vswitchd.sh

Replace ``qemu`` with ``kvm`` in the above scripts to take advance of hardware
virtualization if the platform supports KVM.

Test
====

Install Open vSwitch command line on the host and try some commands:

    ovs-vsctl --db=tcp:10.0.0.11:6640 show

    ovs-vsctl --db=tcp:10.0.0.11:6640 add-br br-int-5 -- set bridge br-int-5 \
    	      datapath_type=netdev
