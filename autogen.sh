#!/bin/sh

if [ -d .git ]; then
	git log --format='%aN' | sort -u > AUTHORS
	git log > ChangeLog
fi

mkdir -p m4
aclocal
autoheader
libtoolize
#intltoolize
autoconf
automake -a -c
