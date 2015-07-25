#!/bin/bash

PACKAGENAME=deadbeef-fb

DATE=$1
if [ -z "$DATE" ]; then
    DATE=`date +%Y%m%d`
fi

FLAG=$2

BUILDROOT=`pwd`

DISTPACKAGENAME=${PACKAGENAME}-devel
INSTALLDIR=${BUILDROOT}/../install

DATE=`date +%Y%m%d`
BINTARGET=${BUILDROOT}/../release/binary/${PACKAGENAME}${FLAG}_${DATE}.tar.gz
SRCTARGET=${BUILDROOT}/../release/source/${PACKAGENAME}${FLAG}_${DATE}_src.tar.gz

rm -rf ${INSTALLDIR}
mkdir -p ${INSTALLDIR}/${PACKAGENAME}
make DESTDIR=${INSTALLDIR} install
libtool --finish ${INSTALLDIR}/${PACKAGENAME}
if [ -d ${INSTALLDIR} ]; then
    cd ${INSTALLDIR}
    for file in ./usr/local/lib/deadbeef/*.so.0.0.0; do
        cp -v $file ./${PACKAGENAME}/`basename $file .0.0.0` || exit $?
    done
    cp -v ${BUILDROOT}/README ./${PACKAGENAME}/ || exit $?
    cp -v ${BUILDROOT}/*install.sh ./${PACKAGENAME}/ || exit $?
    cp -v ${BUILDROOT}/*remove.sh ./${PACKAGENAME}/ || exit $?
    tar -czf $BINTARGET ${PACKAGENAME} || exit $?
    cd ${BUILDROOT}
fi

rm -f ${DISTPACKAGENAME}.tar.gz
make dist PACKAGE=${PACKAGENAME} || exit $?
mv ${DISTPACKAGENAME}.tar.gz ${SRCTARGET} || exit $?

cd ${BUILDROOT}/../release/
ls -lh ${SRCTARGET} ${BINTARGET}
cp -v ${BUILDROOT}/README ./README || exit $?
git status
echo "> Press CTRL+C to abort ..."
sleep 5
git commit -a -m "release ${DATE}" || exit $?
git push
cd ${BUILDROOT}
