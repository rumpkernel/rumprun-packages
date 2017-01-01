#! /bin/bash

rumprun qemu -M 128 -i \
	-I if,vioif,"-net tap,script=no,ifname=tap0" \
	-W if,inet,static,10.0.0.11/24 \
	-b images/ovsdb.ffs,/root/rumprun-packages/ovs/build-cross/ovs/ \
	-- ovsdb-server.bin "-v --remote=ptcp:6640 /root/rumprun-packages/ovs/build-cross/ovs/etc/openvswitch/conf.db"
