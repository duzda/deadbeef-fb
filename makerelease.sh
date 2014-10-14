#!/bin/bash

FLAG=$1

OLDPWD=`pwd`

PACKAGENAME=deadbeef-fb
DISTPACKAGENAME=${PACKAGENAME}-devel
INSTALLDIR=${OLDPWD}/../install

DATE=`date +%Y%m%d`
BINTARGET=${OLDPWD}/../${PACKAGENAME}${FLAG}_${DATE}.tar.gz
SRCTARGET=${OLDPWD}/../${PACKAGENAME}${FLAG}_${DATE}_src.tar.gz

rm -rf ${INSTALLDIR}
mkdir -p ${INSTALLDIR}/${PACKAGENAME}
make DESTDIR=${INSTALLDIR} install
if [ -d ${INSTALLDIR} ]; then
    cd ${INSTALLDIR}
    for file in ./usr/local/lib/deadbeef/*.so.0.0.0; do
        cp -v $file ./${PACKAGENAME}/`basename $file .0.0.0`
    done
    cp -v ${OLDPWD}/README ./${PACKAGENAME}/
    cp -v ${OLDPWD}/*install.sh ./${PACKAGENAME}/
    cp -v ${OLDPWD}/*remove.sh ./${PACKAGENAME}/
    tar -czf $BINTARGET ${PACKAGENAME}
    cd ${OLDPWD}
fi

rm -f ${DISTPACKAGENAME}.tar.gz
make dist PACKAGE=${PACKAGENAME} && mv ${DISTPACKAGENAME}.tar.gz ${SRCTARGET}

ls -lh ${SRCTARGET} ${BINTARGET}
