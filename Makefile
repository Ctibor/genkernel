PACKAGE_VERSION = `/bin/fgrep GK_V= genkernel | sed "s/.*GK_V='\([^']\+\)'/\1/"`
distdir = genkernel-$(PACKAGE_VERSION)

# Add off-Git/generated files here that need to be shipped with releases
EXTRA_DIST = genkernel.8 ChangeLog

genkernel.8: doc/genkernel.8.txt doc/asciidoc.conf Makefile genkernel
	a2x --conf-file=doc/asciidoc.conf --attribute="genkernelversion=$(PACKAGE_VERSION)" \
		 --format=manpage -D . "$<"

ChangeLog:
	git log >$@

clean:
	rm -f $(EXTRA_DIST)

check-git-repository:
	git diff --quiet || { echo 'STOP, you have uncommitted changes in the working directory' ; false ; }
	git diff --cached --quiet || { echo 'STOP, you have uncommitted changes in the index' ; false ; }

dist: check-git-repository $(EXTRA_DIST)
	rm -Rf "$(distdir)" "$(distdir)".tar "$(distdir)".tar.xz
	mkdir "$(distdir)"
	git ls-files -z | xargs -0 cp --no-dereference --parents --target-directory="$(distdir)" \
		$(EXTRA_DIST)
	tar cf "$(distdir)".tar "$(distdir)"
	xz -v "$(distdir)".tar
	rm -Rf "$(distdir)"

.PHONY: clean check-git-repository dist
