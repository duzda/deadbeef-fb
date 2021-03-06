#!/bin/bash

PACKAGENAME=deadbeef-fb

DATE=$1
FLAG=$2

if [ -z "$DATE" ]; then
    DATE=`date -u +%Y%m%d`
fi

BUILDROOT="$(pwd)"
VERSION="$(cat ${BUILDROOT}/version)"

echo "=============================================================================="
echo "Updating tag info for ${PACKAGENAME}${FLAG}-${DATE}_${VERSION} ..."

cd ${BUILDROOT}
git status
echo ">>> Press CTRL+C to abort ..."
sleep 5
git tag -f -m "v${VERSION}" ${DATE} || exit $?
echo "> Pushing tags ..."
git push -f origin ${DATE} || exit $?
