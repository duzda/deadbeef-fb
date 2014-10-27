#!/bin/bash

FLAG=$1

OLDPWD=`pwd`

PACKAGENAME=deadbeef-fb
PACKAGEREL=1

DATE=`date +%Y%m%d`
BINTARGET=${OLDPWD}/../${PACKAGENAME}${FLAG}_${DATE}.tar.gz
SRCTARGET=${OLDPWD}/../${PACKAGENAME}${FLAG}_${DATE}_src.tar.gz

MD5SUM=$(md5sum ${SRCTARGET} | cut -c -32)
SHA1SUM=$(sha1sum ${SRCTARGET} | cut -c -40)

cat PKGBUILD.in \
    | sed s/@PACKAGENAME@/${PACKAGENAME}/g \
    | sed s/@PACKAGEREL@/${PACKAGEREL}/g \
    | sed s/@DATE@/${DATE}/g \
    | sed s/@MD5SUM@/${MD5SUM}/g \
    | sed s/@SHA1SUM@/${SHA1SUM}/g \
    > PKGBUILD
mkaurball
mv -v ${PACKAGENAME}-${DATE}-${PACKAGEREL}.src.tar.gz ${OLDPWD}/../
rm -f PKGBUILD
