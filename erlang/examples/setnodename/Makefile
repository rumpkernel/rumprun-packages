include ../Makefile.inc

ERLFILES=$(wildcard *.erl)
BEAMFILES=$(patsubst %.erl, %.beam, $(ERLFILES))

all: $(BEAMFILES)

%.beam: %.erl
	$(ERLC) $<

clean:
	rm -f $(BEAMFILES)
