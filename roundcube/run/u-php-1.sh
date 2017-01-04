#!/bin/sh
#
# Example script to run the PHP unikernel serving Roundcube webmail.
#
# This configuration assumes two networks, xenbr0 as the public-facing network
# and xenbr1 as the private network used for communication with other unikernel
# domUs, IMAP and SMTP. YMMV.
#
echo $0: Edit me before running! && exit 1

rumprun xen -N u-php-1 -M 256 -di \
    -I xen0,xenif,bridge=xenbr1,vifname=u-php-1-0,mac=02:00:10:01:02:01
    -W xen0,inet,static,10.1.2.1/16 \
    -b data-php.iso,/data \
    -b etc-common.iso,/etc \
    -e PHP_FCGI_MAX_REQUESTS=0 \
    -- \
    ../php/bin/php-cgi.bin \
    -d openssl.cafile=/data/cacert.pem -d date.timezone=UTC \
    -d session.save_path=/tmp \
    -b 8000
