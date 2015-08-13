# Overview

Packaging of [MySQL](http://www.mysql.com/) 5.6.26 for rumprun.

*Experimental work in progress, may eat your data.*

Please report success, failure or anything else to the Rump Kernel mailing list
or IRC: http://wiki.rumpkernel.org/Info:-Community

# Patches

Patches required for cross-compilation are in the `patches/` directory, and
will be applied by the build process.

# Instructions

Building requires an installation of NetBSD makefs (the version available as
makefs on Debian-based distributions works fine).

You will also need an installation of the mysql client libraries and tools to
connect to the mysqld unikernel.

Run `make`:

```
make
```

Bake the final unikernel image:
```
rumpbake xen_pv bin/mysqld.bin bin/mysqld
```

The default installation creates a single root-equivalent user, `rump` with *no
password*, allowing connections from any host. Edit `mysql_rump_bootstrap.sql`
to change this.

# Examples

To start a Xen domU running mysqld, run (for example):

````
rumprun xen "$@" -M 128 -i \
    -b images/stubetc.iso,/etc \
    -b images/data.ffs,/data \
    -I xen0,xenif -W inet,static,10.0.0.10/24 \
    -- \
    bin/mysqld.bin \
        --defaults-file=/data/my.cnf --basedir=/data --user=daemon
````

To connect to the running mysqld on 10.0.0.10:

````
mysql -h 10.0.0.10 -u rump
````

To retrieve some server statistics:
````
mysqladmin -h 10.0.0.10 -u rump status
````

# Caveats

There is currently no way to shut down mysqld cleanly. While `mysqladmin` can
be used to attempt a shutdown, due to issues with rumprun `_exit()` in MT
processes the following will just hang:

````
mysqladmin -h 10.0.0.10 -u rump shutdown

````
