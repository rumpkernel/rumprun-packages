SUBDIRS=$(dir $(wildcard */Makefile))
ERLFILES=$(wildcard */*.erl)
BEAMFILES=$(patsubst %.erl, %.beam, $(ERLFILES))

.PHONY: all

ifeq ($(shell uname),Darwin)
RUMPRUN_GENISOIMAGE=hdiutil makehybrid -iso
else
RUMPRUN_GENISOIMAGE=genisoimage -l -r
endif

all: app.iso

app.iso: compile
	mkdir -p app/modules
	cp $(BEAMFILES) app/modules/
	$(RUMPRUN_GENISOIMAGE) -o app.iso app/modules/

compile:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir all; \
	done

.PHONY: clean

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir $@; \
	done
	rm -rf app
	rm -f app.iso
