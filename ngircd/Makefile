include ../Makefile.inc

UPSTREAM = https://github.com/ngircd/ngircd/archive/rel-22.1.tar.gz

NGIRCD_CONF_OPTS += \
	--without-pam \
	--enable-ipv6 \
	--with-openssl



all: bin/ngircd images/data/conf/ngircd.conf images/data/conf/Commands.txt



# avoid warnings, configure the unprivileged user
images/data/conf/ngircd.conf: build/autogen.sh
	mkdir -p images/data/conf
	cp build/doc/sample-ngircd.conf.tmpl $@
	sed -e 's#;HelpFile = :DOCDIR:/Commands.txt#HelpFile = /data/conf/Commands.txt#' $@ > $@.tmp && mv $@.tmp $@
	sed -e 's#;MotdPhrase = "Hello world!"#MotdPhrase = "IRC server running on a rump kernel!"#' $@ > $@.tmp && mv $@.tmp $@
	sed -e 's#;ServerGID = 65534#ServerGID = 1#' $@ > $@.tmp && mv $@.tmp $@
	sed -e 's#;ServerUID = 65534#ServerUID = 1#' $@ > $@.tmp && mv $@.tmp $@

images/data/conf/Commands.txt: images/data/conf/ngircd.conf
	cp build/doc/Commands.txt $@



bin/ngircd: build/src/ngircd/ngircd
	mkdir -p bin
	cp $< $@

build/src/ngircd/ngircd: build/Makefile
	-$(MAKE) -C build

# aclocal needed to generate the configure script
build/Makefile: build/autogen.sh
	(cd build; ./autogen.sh && ./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(NGIRCD_CONF_OPTS))

build/autogen.sh:
	mkdir -p build
	../scripts/fetch.sh $(UPSTREAM) build/ngircd.tar.gz
	tar --strip-components 1 -x -C build -f build/ngircd.tar.gz



.PHONY: images
images: images/data.iso images/stubetc.iso

images/stubetc.iso: ../stubetc/etc
	genisoimage -l -r -o images/stubetc.iso $<

images/data.iso: images/data/conf/ngircd.conf images/data/conf/Commands.txt
	genisoimage -l -r -o images/data.iso images/data



.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/ngircd
	rm -f images/stubetc.iso images/data.iso
