# prepare the package for release
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
PKGTAR  := $(PKGNAME)_$(PKGVERS).tar.gz


all: build clean

build:
	cd ..; \
	R CMD build $(PKGSRC)


install: build
	cd ..; \
	R CMD INSTALL $(PKGTAR)

clean:
	cd ..; \
	$(RM) $(PKGTAR)

check: build
	cd ..; \
	R CMD check ${PKGTAR}
