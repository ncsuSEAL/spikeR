# prepare the package for release
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
PKGTAR  := $(PKGNAME)_$(PKGVERS).tar.gz
BUILDDIR := "build"

all: doc build clean


build: clean
	R -e "Rcpp::compileAttributes()"
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

check: build
	cd $(BUILDDIR); \
	R CMD check ${PKGTAR}

doc:
   R -e "devtools::document()"

# cmd for CI/CD without pdflatex
ci-check: clean_build build
	cd $(BUILDDIR); \
	R CMD check ${PKGTAR} --no-manual --no-build-vignettes
