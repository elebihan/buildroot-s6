#!/bin/sh

set -e

run_ldconfig()
{
    local ldconfig="${STAGING_DIR}/sbin/ldconfig"
    local version=$(sed -ne 's/BR2_LINUX_KERNEL_VERSION="\([\.0-9]\+\)"/\1/p' \
                        ${BR2_CONFIG})
    local arch=$(sed -ne 's/BR2_ARCH="\(.\+\)"/\1/p' ${BR2_CONFIG})

    case "${arch}" in
        i486|i586|i686)
            arch=i386
            ;;
        powerpc)
            arch=ppc
            ;;
        sh4a)
            arch=sh4
            ;;
        sh4aeb)
            arch=sh4eb
            ;;
    esac

    if [ -z "${version}" ]; then
        version=$(sed -ne 's/BR2_DEFAULT_KERNEL_VERSION="\([\.0-9]\+\)"/\1/p' \
                      ${BR2_CONFIG})
    fi

    local qemu=$(which qemu-"${arch}")
    if [ -n "${qemu}" ]; then
        echo "Updating /etc/ld.so.cache (using ${qemu})"
        echo 'include /etc/ld.so.conf.d/*.conf' > ${TARGET_DIR}/etc/ld.so.conf
        mkdir -p ${TARGET_DIR}/etc/ld.so.conf.d
        ${qemu} -r ${version} ${ldconfig} -v -r ${TARGET_DIR}
    else
        echo "Can not update /etc/ld.so.cache. No QEMU for target available" >&2
        exit 1
    fi
}

compile_s6_rc_db()
{
    echo "Compiling s6-rc service database"
    rm -rf ${TARGET_DIR}/etc/s6-rc/compiled
    mkdir -p ${TARGET_DIR}/etc/s6-rc
    ${HOST_DIR}/usr/bin/s6-rc-compile -v 3 ${TARGET_DIR}/etc/s6-rc/compiled \
               ${TARGET_DIR}/etc/s6-rc/source
}

if grep -q BR2_TARGET_LDCONFIG=y ${BR2_CONFIG}; then
    run_ldconfig
fi
compile_s6_rc_db
