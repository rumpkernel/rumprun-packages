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
rust: $(RUST_DESTDIR)/bin/rustc rustenv.sh

$(RUST_DESTDIR)/bin/rustc: build/rust/config.stamp
	mkdir -p $(RUST_DESTDIR)
	(cd build/rust; $(MAKE) && $(MAKE) install)

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

rustenv.sh: $(RUST_DESTDIR)/bin/rustc
	echo 'export PATH=$(RUST_DESTDIR)/bin:$${PATH}' > rustenv.sh
	echo 'export LD_LIBRARY_PATH="$(RUST_DESTDIR)/lib:$${LD_LIBRARY_PATH}"' >> rustenv.sh
	echo 'export DYLD_LIBRARY_PATH="$(RUST_DESTDIR)/lib:$${DYLD_LIBRARY_PATH}"' >> rustenv.sh

######################################################################
# cargo - The Rust package manager and build tool
######################################################################

.PHONY: cargo
cargo: $(RUST_DESTDIR)/bin/cargo

$(RUST_DESTDIR)/bin/cargo: build/cargo/config.stamp
	mkdir -p $(RUST_DESTDIR)
	(cd build/cargo; \
		export CARGO_HOME=$(CARGO_HOME) && \
		$(MAKE) && \
		$(MAKE) install && \
		echo 'export CARGO_HOME=$(CARGO_HOME)' >> rustenv.sh)

CARGO_CONF_OPTS += \
	--local-rust-root=$(RUST_DESTDIR) \
	--prefix=$(RUST_DESTDIR)

build/cargo/config.stamp: build/cargo/configure
	(cd build/cargo; \
		git submodule update --init && \
		./configure $(CARGO_CONF_OPTS))

build/cargo/configure: $(RUST_DESTDIR)/bin/rustc
	(cd build && git clone --branch $(CARGO_VER) $(CARGO_GIT))

######################################################################
# cargo-rumpbake - Cargo subcommand for invoking rumpbake
######################################################################

.PHONY: cargo-rumpbake
cargo-rumpbake: $(RUST_DESTDIR)/bin/cargo-rumpbake

$(RUST_DESTDIR)/bin/cargo-rumpbake: build/cargo-rumpbake/Cargo.toml
	(cd build/cargo-rumpbake && \
		sh -c '. ../../rustenv.sh ; cargo build --release' && \
		cp target/release/cargo-rumpbake "$@")

build/cargo-rumpbake/Cargo.toml: $(RUST_DESTDIR)/bin/cargo
	mkdir -p build
	(cd build && \
		git clone --branch $(CARGO_RUMPBAKE_VER) $(CARGO_RUMPBAKE_GIT))

.PHONY: clean
clean:
	-$(MAKE) -C build/rust clean
	-$(MAKE) -C build/cargo clean
	rm -f rustenv.sh

.PHONY: cleandir
cleandir: clean
	rm -rf build
