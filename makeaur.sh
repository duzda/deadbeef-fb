#!/bin/bash

PACKAGENAME=deadbeef-fb

DATE=$1
FLAG=$2

if [ -z "$DATE" ]; then
    DATE=`date +%Y%m%d`
fi

BUILDROOT="$(pwd)"
VERSION="$(cat ${BUILDROOT}/version)"

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
    AURPACKAGEDEPS=$3
    AURPACKAGECONFIG=$4

    echo "=============================================================================="
    echo "Building AUR package ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE} v${VERSION} ..."

    cd ${BUILDROOT}
    cat PKGBUILD.in \
        | sed s/@PACKAGENAME@/${AURPACKAGENAME}/g \
        | sed s/@PACKAGEFLAG@/${AURPACKAGEFLAG}/g \
        | sed s/@PACKAGEREL@/${VERSION}/g \
        | sed s/@PACKAGEVER@/${DATE}/g \
        | sed s/@PACKAGEDEPS@/${AURPACKAGEDEPS}/g \
        | sed s/@PACKAGECONFIG@/${AURPACKAGECONFIG}/g \
        | sed s/@SOURCENAME@/${PACKAGENAME}${FLAG}_${DATE}/g \
        | sed s/@MD5SUM@/${MD5SUM}/g \
        | sed s/@SHA1SUM@/${SHA1SUM}/g \
        | sed s/@SHA256SUM@/${SHA256SUM}/g \
        > PKGBUILD
    rm -f "deadbeef-fb_${DATE}_src.tar.gz"
    makepkg --source -f || exit $?
    mkdir -p ${AURDIR}/package
    mv -v ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${VERSION}.src.tar.gz ${AURDIR}/package/

    echo "=============================================================================="
    echo "Testing AUR package ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE} v${VERSION} ..."

    mkdir -p ${AURDIR}/test
    cd ${AURDIR}/test
    tar -xzf ${AURDIR}/package/${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${VERSION}.src.tar.gz || exit $?
    ls -l
    cd ${AURPACKAGENAME}${AURPACKAGEFLAG}
    echo "> $(pwd)"
    namcap PKGBUILD || exit $?
    makepkg -f || exit $?
    namcap ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE}-${VERSION}-any.pkg.tar.xz || exit $?
    cd ${BUILDROOT}

    echo "=============================================================================="
    echo "Updating AUR package ${AURPACKAGENAME}${AURPACKAGEFLAG}-${DATE} v${VERSION} ..."

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
    #git commit -a -m "release ${DATE}" || exit $?
    echo "> Pushing commits ..."
    #git push || exit $? || exit $?
    cd ${BUILDROOT}

}

#            name                 flag    deps   config
make_package "deadbeef-plugin-fb" ""      "gtk2" "--disable-gtk3"
make_package "deadbeef-plugin-fb" "-gtk3" "gtk3" "--disable-gtk2"
