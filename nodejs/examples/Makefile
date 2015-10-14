EXPRESS_VERSION=4.13.3

express-$(EXPRESS_VERSION).iso: | express-$(EXPRESS_VERSION)
	genisoimage -l -r -o $@ express-$(EXPRESS_VERSION)

.PHONY: run_express_hello_world
run_express_hello_world: express-$(EXPRESS_VERSION).iso
	rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i -b express-$(EXPRESS_VERSION).iso,/express ../build/out/Release/node.bin /express/examples/hello-world/index.js

.PHONY: bundle_express_hello_world
bundle_express_hello_world: | node_modules express-$(EXPRESS_VERSION)
	./node_modules/.bin/webpack --target node --module-bind json ./express-$(EXPRESS_VERSION)/examples/hello-world/index.js ../_third_party_main.js
	make -C ..

.PHONY: run_bundled_kvm
run_kvm:
	rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i ../build/out/Release/node.bin

ursa.iso: ursa/test.js | ursa/node_modules/ursa
	genisoimage -l -r -o $@ ursa

.PHONY: run_ursa
run_ursa: ursa.iso
	rumprun kvm -M 160 -i -b ursa.iso,/ursa ../build/out/Release/node.bin /ursa/test.js

node_modules:
	npm install webpack json-loader

express-$(EXPRESS_VERSION):
	curl -L https://github.com/strongloop/express/archive/$(EXPRESS_VERSION).tar.gz | tar -zx
	(cd $@ && npm install --production)

ursa/node_modules/ursa:
	(cd ursa && npm install --production)
	perl -pi -e 's/require\("bindings"\)/process._linkedBinding/' $@/lib/ursa.js
