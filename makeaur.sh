#!/bin/bash

FLAG=$1

OLDPWD=`pwd`

PACKAGENAME=deadbeef-fb

DATE=`date +%Y%m%d`
BINTARGET=${OLDPWD}/../${PACKAGENAME}${FLAG}_${DATE}.tar.gz
SRCTARGET=${OLDPWD}/../${PACKAGENAME}${FLAG}_${DATE}_src.tar.gz

MD5SUM=$(md5sum ${SRCTARGET} | cut -c -32)
SHA1SUM=$(sha1sum ${SRCTARGET} | cut -c -40)

function make_package
{
    AURPACKAGENAME=$1
    AURPACKAGEFLAG=$2
    AURPACKAGEREL=$3
    AURPACKAGEDEPS=$4

    echo "Building AUR package ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${AURPACKAGEREL} ..."

    cat PKGBUILD.in \
        | sed s/@PACKAGENAME@/${AURPACKAGENAME}/g \
        | sed s/@PACKAGEFLAG@/${AURPACKAGEFLAG}/g \
        | sed s/@PACKAGEREL@/${AURPACKAGEREL}/g \
        | sed s/@PACKAGEVER@/${DATE}/g \
        | sed s/@PACKAGEDEPS@/${AURPACKAGEDEPS}/g \
        | sed s/@SOURCENAME@/${PACKAGENAME}${FLAG}_${DATE}/g \
        | sed s/@MD5SUM@/${MD5SUM}/g \
        | sed s/@SHA1SUM@/${SHA1SUM}/g \
        > PKGBUILD
    mkaurball
    mv -v ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${AURPACKAGEREL}.src.tar.gz ${OLDPWD}/../
    rm -f PKGBUILD
}

make_package "deadbeef-plugin-fb" ""      1 gtk2
make_package "deadbeef-plugin-fb" "-gtk3" 1 gtk3
