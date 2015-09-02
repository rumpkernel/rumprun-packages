SUBDIRS=$(dir $(wildcard */Makefile))
ERLFILES=$(wildcard */*.erl)
BEAMFILES=$(patsubst %.erl, %.beam, $(ERLFILES))

.PHONY: all

all: app.iso

app.iso: compile
	mkdir -p app/modules
	cp $(BEAMFILES) app/modules/
	genisoimage -l -r -o app.iso app/modules/

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
