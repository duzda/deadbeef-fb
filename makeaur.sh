#!/bin/bash

PACKAGENAME=deadbeef-fb

DATE=$1
if [ -z "$DATE" ]; then
    DATE=`date +%Y%m%d`
fi

FLAG=$2

BUILDROOT="$(pwd)"
RELEASEDIR=${BUILDROOT}/release
AURDIR=${BUILDROOT}/aur

SRCTARGET=${RELEASEDIR}/source/${PACKAGENAME}${FLAG}_${DATE}_src.tar.gz

ls -l $SRCTARGET
MD5SUM=$(md5sum ${SRCTARGET} | cut -c -32)
SHA1SUM=$(sha1sum ${SRCTARGET} | cut -c -40)
SHA256SUM=$(sha256sum ${SRCTARGET} | cut -c -64)

echo "> MD5:    ${MD5SUM}"
echo "> SHA1:   ${SHA1SUM}"
echo "> SHA256: ${SHA256SUM}"

mkdir -p ${AURDIR}

function make_package
{
    AURPACKAGENAME=$1
    AURPACKAGEFLAG=$2
    AURPACKAGEREL=$3
    AURPACKAGEDEPS=$4
    AURPACKAGECONFIG=$5

    echo "=============================================================================="
    echo "Building AUR package ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${AURPACKAGEREL} ..."

    cd ${BUILDROOT}
    cat PKGBUILD.in \
        | sed s/@PACKAGENAME@/${AURPACKAGENAME}/g \
        | sed s/@PACKAGEFLAG@/${AURPACKAGEFLAG}/g \
        | sed s/@PACKAGEREL@/${AURPACKAGEREL}/g \
        | sed s/@PACKAGEVER@/${DATE}/g \
        | sed s/@PACKAGEDEPS@/${AURPACKAGEDEPS}/g \
        | sed s/@PACKAGECONFIG@/${AURPACKAGECONFIG}/g \
        | sed s/@SOURCENAME@/${PACKAGENAME}${FLAG}_${DATE}/g \
        | sed s/@MD5SUM@/${MD5SUM}/g \
        | sed s/@SHA1SUM@/${SHA1SUM}/g \
        | sed s/@SHA256SUM@/${SHA256SUM}/g \
        > PKGBUILD
    makepkg --source -f || exit $?
    rm -f "deadbeef-fb_${DATE}_src.tar.gz"
    mkdir -p ${AURDIR}/package
    mv -v ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${AURPACKAGEREL}.src.tar.gz ${AURDIR}/package/

    echo "=============================================================================="
    echo "Testing AUR package ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${AURPACKAGEREL} ..."

    mkdir -p ${AURDIR}/test
    cd ${AURDIR}/test
    tar -xzf ${AURDIR}/package/${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${AURPACKAGEREL}.src.tar.gz || exit $?
    ls -l
    cd ${AURPACKAGENAME}${AURPACKAGEFLAG}
    echo "> $(pwd)"
    namcap PKGBUILD || exit $?
    makepkg -f || exit $?
    namcap ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${AURPACKAGEREL}-any.pkg.tar.xz || exit $?
    cd ${BUILDROOT}

    echo "=============================================================================="
    echo "Updating AUR package ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${AURPACKAGEREL} ..."

    cd ${AURDIR}
    if [ ! -d ${AURPACKAGENAME}${AURPACKAGEFLAG} ]; then
        echo "> Getting a fresh copy of the AUR repository ..."
        git clone ssh://aurssh/${AURPACKAGENAME}${AURPACKAGEFLAG}.git || exit $?
    fi
    cd ${AURPACKAGENAME}${AURPACKAGEFLAG}
    git pull || exit $?
    cp -v ${BUILDROOT}/PKGBUILD ./PKGBUILD || exit $?
    namcap PKGBUILD || exit $?
    mksrcinfo || exit $?
    git add PKGBUILD || exit $?
    git add .SRCINFO || exit $?
    git status
    echo ">>> Press CTRL+C to abort ..."
    sleep 5
    git commit -a -m "release ${DATE}" || exit $?
    git push || exit $?
    cd ${BUILDROOT}

}

make_package "deadbeef-plugin-fb" ""      1 "gtk2" "--disable-gtk3"
make_package "deadbeef-plugin-fb" "-gtk3" 1 "gtk3" "--disable-gtk2"
