# prepare the package for release
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
PKGTAR  := $(PKGNAME)_$(PKGVERS).tar.gz
BUILDDIR := "build"

all: build clean


build:
	mkdir -p $(BUILDDIR) && \
	R CMD build . 
	mv $(PKGTAR) $(BUILDDIR)

clean_build:
	rm -rf $(BUILDDIR)

install: build
	cd $(BUILDDIR); \
	R CMD INSTALL $(PKGTAR)

clean:
	cd $(BUILDDIR); \
	$(RM) $(PKGTAR)

check: clean_build build
	cd $(BUILDDIR); \
	R CMD check ${PKGTAR}
