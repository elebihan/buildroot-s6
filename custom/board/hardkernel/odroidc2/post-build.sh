#!/bin/sh

set -e

LOCAL_SERVICES="${TARGET_DIR}/etc/s6-rc/source/bundle-local/contents"

echo "Enabling s6-rc services"
if ! grep -q getty-tty1 "${LOCAL_SERVICES}"; then
    echo getty-tty1 >> "${LOCAL_SERVICES}"
fi
