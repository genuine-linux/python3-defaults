#!/usr/bin/make -f

INSTALL ?= install
PREFIX ?= /usr/local
VERSION = 3.7.2

clean:
	find . -name '*.py[co]' -delete
	find . -name __pycache__ -type d | xargs rm -rf
	rm -f .coverage

install:
	$(INSTALL) -m 755 -d $(DESTDIR)$(PREFIX)/bin \
		$(DESTDIR)$(PREFIX)/share/python3/runtime.d \
		$(DESTDIR)$(PREFIX)/share/man/man1 \
		$(DESTDIR)$(PREFIX)/share/applications
	$(INSTALL) -m 755 runtime.d/* $(DESTDIR)$(PREFIX)/share/python3/runtime.d/
	$(INSTALL) -m 755 -d $(DESTDIR)$(PREFIX)/share/python3/genpython $(DESTDIR)$(PREFIX)/bin
	$(INSTALL) -m 644 genpython/*.py $(DESTDIR)$(PREFIX)/share/python3/genpython/
	$(INSTALL) -m 755 py3compile $(DESTDIR)$(PREFIX)/bin/
	$(INSTALL) -m 644 py3compile.1 $(DESTDIR)$(PREFIX)/share/man/man1/py3compile.1
	sed -i -e 's/DEVELV/$(VERSION)/' $(DESTDIR)$(PREFIX)/bin/py3compile
	$(INSTALL) -m 755 py3clean $(DESTDIR)$(PREFIX)/bin/
	sed -i -e 's/DEVELV/$(VERSION)/' $(DESTDIR)$(PREFIX)/bin/py3clean
	$(INSTALL) -m 644 py3clean.1 $(DESTDIR)$(PREFIX)/share/man/man1/py3clean.1
	$(INSTALL) -m 644 idle.1 $(DESTDIR)$(PREFIX)/share/man/man1/idle.1
	$(INSTALL) -m 644 idle.desktop $(DESTDIR)$(PREFIX)/share/applications/idle.desktop
	$(INSTALL) -m 644 python3.desktop $(DESTDIR)$(PREFIX)/share/applications/python3.desktop
	$(INSTALL) -m 644 py3versions.1 $(DESTDIR)$(PREFIX)/share/man/man1/py3versions.1
	$(INSTALL) -m 755 py3versions.py $(DESTDIR)$(PREFIX)/bin/py3versions
	$(INSTALL) -m 755 py3versions.py $(DESTDIR)$(PREFIX)/bin/py3versions
	$(INSTALL) -m 644 python.mk $(DESTDIR)$(PREFIX)/share/python3/python.mk
	$(INSTALL) -m 644 genuine_defaults $(DESTDIR)$(PREFIX)/share/python3/genuine_defaults
	cp -pv valgrind-python.supp $(DESTDIR)$(PREFIX)/usr/lib/valgrind/python3.supp

# TESTS
tests:
	nosetests3 --with-doctest --with-coverage

check_versions:
	@PYTHONPATH=. set -e; \
	DEFAULT=`python3 -c 'import genpython.version as v; print(v.vrepr(v.DEFAULT))'`;\
	SUPPORTED=`python3 -c 'import genpython.version as v; print(" ".join(sorted(v.vrepr(v.SUPPORTED))))'`;\
	GEN_DEFAULT=`sed -rn 's,^default-version = python([0.9.]*),\1,p' genuine/genuine_defaults`;\
	GEN_SUPPORTED=`sed -rn 's|^supported-versions = (.*)|\1|p' genuine/genuine_defaults | sed 's/python//g;s/,//g'`;\
	[ "$$DEFAULT" = "$$GEN_DEFAULT" ] || \
	(echo 'Please update DEFAULT in genpython/version.py' >/dev/stderr; false);\
	[ "$$SUPPORTED" = "$$GEN_SUPPORTED" ] || \
	(echo 'Please update SUPPORTED in genpython/version.py' >/dev/stderr; false)

.PHONY: clean tests test% check_versions
