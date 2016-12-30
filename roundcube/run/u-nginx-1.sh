#!/bin/sh
#
# Example script to run the Ngninx unikernel serving Roundcube webmail.
#
# This configuration assumes two networks, xenbr0 as the public-facing network
# and xenbr1 as the private network used for communication with other unikernel
# domUs, IMAP and SMTP. YMMV.
#
echo $0: Edit me before running! && exit 1

rumprun xen \
    -N u-nginx-1 \
    -di -M 128 \
    -I xen0,mac=00:16:3e:XX:XX:XX,bridge=xenbr0 \
    -W xen0,inet,dhcp \
    -I xen1,xenif,bridge=xenbr1,vifname=u-nginx-1-1,mac=02:00:10:01:01:02
    -W xen1,inet,static,10.1.1.2/16 \
    -b data-nginx.iso,/data \
    -b etc-common.iso,/etc \
    -- ../nginx/bin/nginx.bin -c /data/conf/nginx.conf
