#!/bin/bash

PACKAGENAME=deadbeef-fb

DATE=$1
FLAG=$2

if [ -z "$DATE" ]; then
    DATE=`date +%Y%m%d`
fi

BUILDROOT="$(pwd)"
VERSION="$(cat ${BUILDROOT}/version)"

DISTPACKAGENAME=${PACKAGENAME}-devel
INSTALLDIR=${BUILDROOT}/install
RELEASEDIR=${BUILDROOT}/release

BINTARGET=${RELEASEDIR}/binary/${PACKAGENAME}${FLAG}_${DATE}.tar.gz
SRCTARGET=${RELEASEDIR}/source/${PACKAGENAME}${FLAG}_${DATE}_src.tar.gz

mkdir -p ${RELEASEDIR}/binary
mkdir -p ${RELEASEDIR}/source

echo "=============================================================================="
echo "Building binary release for ${PACKAGENAME}${FLAG} v${VERSION} ..."

cd ${BUILDROOT}
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
echo "Building source release for ${PACKAGENAME}${FLAG} v${VERSION} ..."

cd ${BUILDROOT}
rm -f ${DISTPACKAGENAME}.tar.gz
make dist PACKAGE=${PACKAGENAME} || exit $?
mv ${DISTPACKAGENAME}.tar.gz ${SRCTARGET} || exit $?

echo "=============================================================================="
echo "Updating releases for ${PACKAGENAME}${FLAG} v${VERSION} ..."

cd ${RELEASEDIR}
if [ ! -d ${PACKAGENAME} ]; then
    echo "> Getting a fresh copy of the release repository ..."
    git clone -b release git@gitlab.com:zykure/${PACKAGENAME}.git || exit $?
fi
cd ${PACKAGENAME}
mkdir -p binary
mkdir -p source
cp ${BUILDROOT}/README ./README || exit $?
cp ${BINTARGET} ./binary/ || exit $?
cp ${SRCTARGET} ./source/ || exit $?
git add README || exit $?
git add binary/ || exit $?
git add source/ || exit $?
git status
echo ">>> Press CTRL+C to abort ..."
sleep 5
git commit -a -m "release ${DATE}" || exit $?
echo "> Pushing commits ..."
git push || exit $?
git tag -f -m "v${VERSION}" ${DATE} || exit $?
echo "> Pushing tags ..."
git push -f origin ${DATE} || exit $?
cd ${BUILDROOT}
