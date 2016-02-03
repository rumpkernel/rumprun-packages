include ../Makefile.inc

EXPRESS_VERSION=4.13.3
GHOST_VERSION=0.7.5

.PHONY: run_express_hello_world
run_express_hello_world: express-$(EXPRESS_VERSION).iso
	rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i -b express-$(EXPRESS_VERSION).iso,/express ../$(NODE_BIN).bin /express/examples/hello-world/index.js

.PHONY: bundle_express_hello_world
bundle_express_hello_world: zipload.sh express-$(EXPRESS_VERSION).zip
	./zipload.sh ./express-$(EXPRESS_VERSION)/examples/hello-world/index.js < express-$(EXPRESS_VERSION).zip > hello-world.js
	ln -sf examples/hello-world.js ../rumpmain.js
	make -C ..

.PHONY: run_bundled_express_hello_world
run_bundled_express_hello_world:
	rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i ../$(NODE_BIN).bin

NAD=../../../node_modules/.bin/nad
.PHONY: inject_ursa
inject_ursa: | node_modules ursa/node_modules/ursa
	(cd ursa/node_modules/ursa; $(NAD) configure --nodedir ../../../../$(BUILD_DIR); $(NAD) inject)
	NODE_PATH=../examples/ursa/node_modules/ursa/node_modules make -C ..

.PHONY: run_ursa
run_ursa: ursa.iso
	rumprun kvm -M 160 -i -b ursa.iso,/ursa ../$(NODE_BIN).bin /ursa/test.js

.PHONY: bundle_ghost
bundle_ghost: zipload.sh Ghost-$(GHOST_VERSION).zip
	./zipload.sh ./Ghost-$(GHOST_VERSION)/index.js < Ghost-$(GHOST_VERSION).zip > ghost-$(GHOST_VERSION).js
	ln -sf examples/ghost-$(GHOST_VERSION).js ../rumpmain.js
	make -C ..

.PHONY: inject_ghost
inject_ghost: | node_modules Ghost-$(GHOST_VERSION)
	(cd Ghost-$(GHOST_VERSION)/node_modules/sqlite3; mv binding.gyp binding.gyp.orig; sed -e 's/<(module_name)/sqlite3/g' -e "s/sqlite !=/'internal' !=/" -e "s:\(deps/\):$$PWD/\1:g" -e "s:\.\./:$$PWD/:g" binding.gyp.orig > binding.gyp; mv deps/sqlite3.gyp deps/sqlite3.gyp.orig; sed -e "s:\.\./:$$PWD/:g" deps/sqlite3.gyp.orig > deps/sqlite3.gyp; $(NAD) configure --nodedir ../../../../$(BUILD_DIR); $(NAD) inject)
	NODE_PATH=../examples/Ghost-$(GHOST_VERSION)/node_modules/sqlite3/node_modules make -C ..

.PHONY: run_bundled_ghost
run_bundled_ghost:
	rumprun kvm -M 1024 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i -g '-nographic -vga none' ../$(NODE_BIN).bin

node_modules:
	npm install nad

bootstrap.js: zipload.js | ../dl/jszip.min.js
	cat ../dl/jszip.min.js zipload.js > $@

../dl/jszip.min.js:
	curl -L https://raw.githubusercontent.com/Stuk/jszip/master/dist/jszip.min.js > $@

express-$(EXPRESS_VERSION): | ../dl/express-$(EXPRESS_VERSION).tar.gz
	tar -zxf ../dl/express-$(EXPRESS_VERSION).tar.gz
	(cd $@ && npm install --production)

../dl/express-$(EXPRESS_VERSION).tar.gz:
	curl -L -o $@ https://github.com/strongloop/express/archive/$(EXPRESS_VERSION).tar.gz

express-$(EXPRESS_VERSION).iso: express-$(EXPRESS_VERSION)
	genisoimage -l -r -o $@ express-$(EXPRESS_VERSION)

express-$(EXPRESS_VERSION).zip: express-$(EXPRESS_VERSION)
	rm -f $@
	zip -r $@ express-$(EXPRESS_VERSION)

ursa/node_modules/ursa:
	(cd ursa && npm install --production)

ursa.iso: ursa/test.js | ursa/node_modules/ursa
	genisoimage -l -r -o $@ ursa

Ghost-$(GHOST_VERSION): | ../dl/ghost-$(GHOST_VERSION).zip
	(mkdir $@ && cd $@ && unzip ../../dl/ghost-$(GHOST_VERSION).zip && npm install --production)
	
../dl/ghost-$(GHOST_VERSION).zip:
	curl -L -o $@ https://ghost.org/zip/ghost-$(GHOST_VERSION).zip

Ghost-$(GHOST_VERSION).zip: Ghost-$(GHOST_VERSION)
	rm -f $@
	zip -r $@ Ghost-$(GHOST_VERSION)

ghost_data.img: | Ghost-$(GHOST_VERSION)
	dd if=/dev/zero of=$@ bs=1048576 seek=10 count=0
	mkfs.ext2 -F $@
	sed -e 's/127\.0\.0\.1/0.0.0.0/g' -e 's/\( *\)\(url:\)/\1privacy: { useUpdateCheck: false },\n\1\2/g' Ghost-$(GHOST_VERSION)/config.example.js | e2cp -O 0 -G 0 - $@:config.js
	e2mkdir -O 0 -G 0 $@:content
	find Ghost-$(GHOST_VERSION)/content -mindepth 1 -type d -printf '$@:content/%P\0' | xargs -0 e2mkdir -O 0 -G 0
	find Ghost-$(GHOST_VERSION)/content -type f -printf '%P\0' | xargs -0 -n 1 -I % e2cp -O 0 -G 0 "Ghost-$(GHOST_VERSION)/content/%" "$@:content/%"

.PHONY: clean
clean:
	rm -rf *.iso node_modules ursa/node_modules express-* hello-world.js
