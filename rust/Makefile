include ../Makefile.inc
RUST_GIT=https://github.com/rust-lang/rust.git
RUST_VER=c9c79084

CARGO_GIT=https://github.com/rust-lang/cargo.git
CARGO_VER=0.5.0

CARGO_RUMPBAKE_GIT=https://github.com/gandro/cargo-rumpbake.git
CARGO_RUMPBAKE_VER=0.5.0

ifneq (x86_64-rumprun-netbsd,$(RUMPRUN_TOOLCHAIN_TUPLE))
$(error Rust currently only supports x86_64-rumprun-netbsd)
endif

RUST_DESTDIR ?= $(abspath build/destdir)
CARGO_HOME := $(RUST_DESTDIR)/cargo

all: rust cargo cargo-rumpbake

######################################################################
# rust - The Rust compiler and standard library
######################################################################

.PHONY: rust
rust: build/rust.stamp rustenv.sh

build/rust.stamp: build/rust/config.stamp
	mkdir -p $(RUST_DESTDIR)
	(cd build/rust; $(MAKE) && $(MAKE) install)
	touch $@

RUST_CONF_OPTS += \
	--target=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	--prefix=$(RUST_DESTDIR) \
	--enable-debug

build/rust/config.stamp: build/rust/configure
	(cd build/rust; ./configure $(RUST_CONF_OPTS))

build/rust/configure:
	mkdir -p build
	(cd build && \
		git clone $(RUST_GIT) && \
		cd rust && git checkout $(RUST_VER))

rustenv.sh: build/rust.stamp
	echo 'export PATH=$(RUST_DESTDIR)/bin:$${PATH}' > rustenv.sh
	echo 'export LD_LIBRARY_PATH="$(RUST_DESTDIR)/lib:$${LD_LIBRARY_PATH}"' >> rustenv.sh
	echo 'export DYLD_LIBRARY_PATH="$(RUST_DESTDIR)/lib:$${DYLD_LIBRARY_PATH}"' >> rustenv.sh
	echo 'export CARGO_HOME=$(CARGO_HOME)' >> rustenv.sh

######################################################################
# cargo - The Rust package manager and build tool
######################################################################

.PHONY: cargo
cargo: build/cargo.stamp

build/cargo.stamp: build/cargo/config.stamp
	mkdir -p $(RUST_DESTDIR)
	(cd build/cargo; \
		export CARGO_HOME=$(CARGO_HOME) && \
		$(MAKE) && $(MAKE) install)
	touch $@

CARGO_CONF_OPTS += \
	--local-rust-root=$(RUST_DESTDIR) \
	--prefix=$(RUST_DESTDIR)

build/cargo/config.stamp: build/cargo/configure build/rust.stamp
	(cd build/cargo; \
		git submodule update --init && \
		./configure $(CARGO_CONF_OPTS))

build/cargo/configure:
	mkdir -p build
	(cd build && git clone --branch $(CARGO_VER) $(CARGO_GIT))

######################################################################
# cargo-rumpbake - Cargo subcommand for invoking rumpbake
######################################################################

.PHONY: cargo-rumpbake
cargo-rumpbake: build/cargo-rumpbake.stamp

build/cargo-rumpbake.stamp: build/cargo-rumpbake/Cargo.toml build/cargo.stamp rustenv.sh
	(cd build/cargo-rumpbake && \
		sh -c '. ../../rustenv.sh && cargo build')
	cp build/cargo-rumpbake/target/debug/cargo-rumpbake \
		$(RUST_DESTDIR)/bin/cargo-rumpbake
	touch $@

build/cargo-rumpbake/Cargo.toml:
	mkdir -p build
	(cd build && \
		git clone --branch $(CARGO_RUMPBAKE_VER) $(CARGO_RUMPBAKE_GIT))

.PHONY: clean
clean:
	-$(MAKE) -C build/rust clean
	-$(MAKE) -C build/cargo clean
	rm -rf build/cargo-rumpbake/target
	rm -f build/rust.stamp build/cargo.stamp build/cargo-rumpbake.stamp
	rm -f rustenv.sh

.PHONY: cleandir
cleandir: clean
	rm -rf build
