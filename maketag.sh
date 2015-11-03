#!/bin/bash

PACKAGENAME=deadbeef-fb

DATE=$1
FLAG=$2

if [ -z "$DATE" ]; then
    DATE=`date +%Y%m%d`
fi

BUILDROOT="$(pwd)"
VERSION="$(cat ${BUILDROOT}/version)"

echo "=============================================================================="
echo "Updating tag info for ${PACKAGENAME}${FLAG} v${VERSION} ..."

cd ${BUILDROOT}
git status
echo ">>> Press CTRL+C to abort ..."
sleep 5
git commit -a || exit $?
echo "> Pushing commits ..."
git push || exit $?
git tag -f -m "v${VERSION}" ${DATE} || exit $?
echo "> Pushing tags ..."
git push -f origin ${DATE} || exit $?
