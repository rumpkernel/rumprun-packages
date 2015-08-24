include ../Makefile.inc
UPSTREAM=https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.2/roundcubemail-1.1.2-complete.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: build/index.php data-php.iso data-nginx.iso etc-common.iso data-mysql.ffs

data-mysql.ffs: config/bootstrap.sql
	mkdir -p data-mysql
	../mysql/scripts/mysql-bootstrap.sh data-mysql config/bootstrap.sql
	../mysql/scripts/rumprun-makefs.sh -u 1 -g 1 data-mysql.ffs data-mysql

data-php.iso: build/index.php config/config-gen.inc.php config/config.inc.php
	mkdir -p data-common/www
	cd build && \
	    cp -r config index.php plugins program robots.txt skins vendor \
	        ../data-common/www
	cp config/config.inc.php config/config-gen.inc.php \
	        data-common/www/config
	genisoimage -q -l -r -o data-php.iso data-common

data-nginx.iso: data-php.iso config/nginx/* config/nginx/cert.pem
	mkdir -p data-nginx
	cp -r config/nginx data-nginx/conf
	genisoimage -q -l -r -o data-nginx.iso data-common data-nginx

etc-common.iso: config/etc-hosts ../stubetc/etc/*
	mkdir -p etc-common
	cp -r config/etc-hosts etc-common/hosts
	genisoimage -q -l -r -o etc-common.iso etc-common ../stubetc/etc

config/bootstrap.sql: build/index.php config/db-password
	scripts/mkbootstrap-sql.sh config

config/config-gen.inc.php: config/db-password config/session-key
	scripts/mkconfig-gen.sh config

config/db-password:
	scripts/genkey.sh 16 > $@

config/session-key:
	scripts/genkey.sh 24 > $@

config/nginx/cert.pem:
	openssl req \
	    -subj '/CN=localhost/O=self-signed/C=US' \
	    -new -newkey rsa:2048 -sha256 -days 365 -nodes \
	    -x509 -keyout config/nginx/cert.key \
	    -out config/nginx/cert.pem

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/index.php: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -zx --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: clean
clean:
	rm -f *.iso *.ffs
	rm -rf data-common data-nginx etc-common data-mysql

.PHONY: distclean
distclean: clean
	rm -rf build
	rm -f config/bootstrap.sql
	rm -f config/config-gen.inc.php config/db-password config/session-key
	rm -f config/nginx/cert.key config/nginx/cert.pem
