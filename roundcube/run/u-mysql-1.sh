#!/bin/sh
#
# Example script to run the MySQL unikernel serving the database for Roundcube
# webmail.
#
# This configuration assumes two networks, xenbr0 as the public-facing network
# and xenbr1 as the private network used for communication with other unikernel
# domUs, IMAP and SMTP. YMMV.
#
echo $0: Edit me before running! && exit 1

rumprun xen -N u-mysql-1 -M 128 -i \
    -I xen0,xenif,bridge=xenbr1,vifname=u-mysql-1-0,mac=02:00:10:01:04:01
    -W xen0,inet,static,10.1.4.1/16 \
    -b data-mysql.ffs,/data \
    -b etc-common.iso,/etc \
    -- \
    ../mysql/bin/mysqld.bin \
        --defaults-file=/data/my.cnf --basedir=/data --user=daemon
