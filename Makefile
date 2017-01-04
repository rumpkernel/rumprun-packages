SUBDIRS=$(dir $(wildcard */Makefile))
.PHONY: world all $(SUBDIRS)

all:
	@echo "To build a package with automated build support, run 'make'"
	@echo "in the package directory."
	@echo
	@echo "To build all packages, run 'make world'."

world: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ all
