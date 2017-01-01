#! /bin/bash

rumprun qemu -M 128 -i -b images/ovsdb.ffs,/root/rumprun-packages/ovs/build-cross/ovs/ \
	-- ovsdb-tool.bin \
	create "/root/rumprun-packages/ovs/build-cross/ovs/etc/openvswitch/conf.db"
