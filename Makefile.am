release: all
	./makerelease.sh
	./makeaur.sh

#SUBDIRS = \
#	intl \
#	po

#INTLTOOL_FILES = \
#	intltool-extract.in \
#	intltool-merge.in \
#	intltool-update.in

#DISTCLEANFILES = \
#	intltool-extract \
#	intltool-merge \
#	intltool-update \
#	po/.intltool-merge-cache

filebrowser_SOURCES = \
	filebrowser.c filebrowser.h \
	support.c support.h \
	utils.c utils.h

if HAVE_GTK2
if HAVE_GTK3
pkglib_LTLIBRARIES = ddb_misc_filebrowser_GTK2.la ddb_misc_filebrowser_GTK3.la
else
pkglib_LTLIBRARIES = ddb_misc_filebrowser_GTK2.la
endif
else
if HAVE_GTK3
pkglib_LTLIBRARIES = ddb_misc_filebrowser_GTK3.la
endif
endif


EXTRA_FLAGS = -DPLUGIN_VERSION_MAJOR=$(shell cat version | cut -d . -f 1) -DPLUGIN_VERSION_MINOR=$(shell cat version | cut -d . -f 2)

# normal lib
if DEBUG
EXTRA_FLAGS = $(EXTRA_FLAGS) -g3 -ggdb -Wall
else
EXTRA_FLAGS = $(EXTRA_FLAGS) -Werror
endif

if HAVE_GTK2
ddb_misc_filebrowser_GTK2_la_SOURCES = $(filebrowser_SOURCES)
ddb_misc_filebrowser_GTK2_la_LDFLAGS = -module
ddb_misc_filebrowser_GTK2_la_LIBADD  = $(LDADD) $(GTK2_DEPS_LIBS)
ddb_misc_filebrowser_GTK2_la_CFLAGS  = -std=c99 $(GTK2_DEPS_CFLAGS) $(EXTRA_FLAGS)
endif
if HAVE_GTK3
ddb_misc_filebrowser_GTK3_la_SOURCES = $(filebrowser_SOURCES)
ddb_misc_filebrowser_GTK3_la_LDFLAGS = -module
ddb_misc_filebrowser_GTK3_la_LIBADD  = $(LDADD) $(GTK3_DEPS_LIBS)
ddb_misc_filebrowser_GTK3_la_CFLAGS  = -std=c99 $(GTK3_DEPS_CFLAGS) $(EXTRA_FLAGS)
endif

docsdir = $(docdir)
docs_DATA = README COPYING AUTHORS ChangeLog

dist_data_DATA =

EXTRA_DIST = \
	userinstall.sh quickinstall.sh userremove.sh quickremove.sh \
	$(docs_DATA)
#$(INTLTOOL_FILES)

ACLOCAL_AMFLAGS = -I m4
