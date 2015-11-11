#!/bin/sh

set -e

rm -rf ${TARGET_DIR}/var/run/dropbear
rm -rf ${TARGET_DIR}/etc/dropbear
mkdir -p ${TARGET_DIR}/etc/dropbear

echo "Compiling s6-rc service database"
rm -rf ${TARGET_DIR}/etc/s6-rc/compiled
mkdir -p ${TARGET_DIR}/etc/s6-rc
${HOST_DIR}/usr/bin/s6-rc-compile -v 3 ${TARGET_DIR}/etc/s6-rc/compiled \
           ${TARGET_DIR}/etc/s6-rc/source
