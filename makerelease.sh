#!/bin/bash

PACKAGENAME=deadbeef-fb

DATE=$1
if [ -z "$DATE" ]; then
    DATE=`date +%Y%m%d`
fi

FLAG=$2

BUILDROOT="$(pwd)"

DISTPACKAGENAME=${PACKAGENAME}-devel
INSTALLDIR=${BUILDROOT}/install
RELEASEDIR=${BUILDROOT}/release

BINTARGET=${RELEASEDIR}/binary/${PACKAGENAME}${FLAG}_${DATE}.tar.gz
SRCTARGET=${RELEASEDIR}/source/${PACKAGENAME}${FLAG}_${DATE}_src.tar.gz

mkdir -p ${RELEASEDIR}/binary
mkdir -p ${RELEASEDIR}/source

echo "=============================================================================="
echo "Building binary release for ${PACKAGENAME}${FLAG} ..."

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

echo "=============================================================================="
echo "Building source release for ${PACKAGENAME}${FLAG} ..."

rm -f ${DISTPACKAGENAME}.tar.gz
make dist PACKAGE=${PACKAGENAME} || exit $?
mv ${DISTPACKAGENAME}.tar.gz ${SRCTARGET} || exit $?

echo "=============================================================================="
echo "Updating releases for ${PACKAGENAME}${FLAG} ..."

cd ${RELEASEDIR}
if [ ! -d ${PACKAGENAME} ]; then
    echo "> Getting a fresh copy of the release repository ..."
    git clone -b release git@gitlab.com:zykure/${PACKAGENAME}.git || exit $?
fi
cd ${PACKAGENAME}
cp ${BUILDROOT}/README ./README || exit $?
cp ${BINTARGET} ./$(basename ${BINTARGET}) || exit $?
cp ${SRCTARGET} ./$(basename ${SRCTARGET}) || exit $?
git add README || exit $?
git add $(basename ${BINTARGET}) || exit $?
git add $(basename ${SRCTARGET}) || exit $?
git status
echo ">>> Press CTRL+C to abort ..."
sleep 5
git commit -a -m "release ${DATE}" || exit $?
git push || exit $?
cd ${BUILDROOT}
