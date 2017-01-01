#! /bin/bash

rumprun qemu -M 128 -i \
	-I if,vioif,"-net tap,script=no,ifname=tap1" \
	-W if,inet,static,10.0.0.12/24 \
	-b images/ovs-vswitchd.ffs,/root/rumprun-packages/ovs/build-cross/ovs/ \
	-- ovs-vswitchd.bin "-v tcp:10.0.0.11:6640"
