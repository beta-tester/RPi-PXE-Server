#!/usr/bin/bash

# ... break=top
# ... break=...
# ... break=premount
# ... break=init
# ... debug
#
# sudo unsquashfs -d /tmp/test -f /srv/nfs/tails-x64/live/filesystem.squashfs
# $ ls  /tmp/test/bin/live-*
# $ ls -r /tmp/test/lib/live/*

# 2025-09-26 for tails 7.0, add missing lib for kmod
# 2024-02-27 for tails 6.0, renamed to all-net-blocklist.conf
# 2024-02-27 for tails 6.0, updated path from /lib/modules/ to /usr/lib/modules/
# 2023-09-11 skip network de-init on boot option "break=init" to keep network alive for debugging
# 2021-11-07 /conf/net_drivers.tar.xz, /conf/conf.d/zzzz-hotfix-pxe, /etc/live/boot/zzzz-hotfix-pxe

# requires:
#   squashfs-tools  (unsquashfs)
#   initramfs-tools (cpio, unmkinitramfs)
#   xz-utils        (xz)
#   zstd            (zstd)

# location, where to store temporary files
TMP=/tmp/tails-net

# full filename of the filesystem.squashfs from tails ISO
SRC=/srv/nfs/tails-x64/live/filesystem.squashfs

# full filename of the hotfix-pxe image
DST=/srv/nfs/tails-x64-hotfix


if [[ -z "${TMP}" ]] || [[ -z "${SRC}" ]] || [[ -z "${DST}" ]]; then
    echo "ERROR: undefined variable"
    return -1
fi

if ! [[ -d "$(dirname ${TMP:?})" ]] && ! [[ -r "${SRC:?}" ]] && ! [[ -d "$(dirname ${DST:?})" ]]; then
    echo "ERROR: wrong file or folder"
    return -2
fi


# kernel version of tails
KVER=$(basename $(unsquashfs -l "${SRC:?}" -e /usr/lib/modules/ | grep /usr/lib/modules/ | head -n 1))
(( $? != 0 )) && return -4

# test if kernel version is correct
if [[ -n "${KVER}" ]]; then
    echo "INFO: KVER='${KVER:?}'"
else
    echo "ERROR: unknown kernel version"
    return -3
fi

do_modules() {
# extract missing network kernel drivers modules from tails
sudo unsquashfs \
    -d "${TMP:?}" \
    -f "${SRC:?}" \
    -e "/usr/lib/modules/${KVER:?}/kernel/drivers/net/phy" \
    -e "/usr/lib/modules/${KVER:?}/kernel/drivers/net/ethernet" \
    -e "/usr/bin/kmod" \
    -e "/usr/lib/x86_64-linux-gnu/liblzma.so.*" \
    ;
(( $? != 0 )) && exit -4
}


do_patch_top() {
# add hotfix for pxe boot to initrd image
[[ -e "${TMP:?}/conf/conf.d/" ]] || sudo mkdir -p "${TMP:?}/conf/conf.d/"
cat << EOF | sudo tee "${TMP:?}/conf/conf.d/zzzz-hotfix-pxe" &>/dev/null
#!/usr/bin/sh

patch_top()
{
    # check if we dealing with same kernel version
    if [ "\$(uname -r)" != "${KVER:?}" ]; then
        . /scripts/functions
        log_failure_msg "wrong kernel version. '\$(uname -r)'!='${KVER:?}'"
        panic "please visit: https://github.com/beta-tester/RPi-PXE-Server/issues/31"
    fi

    # comment out all blacklist entries
    sed "s/^install/# install/g" -i /etc/modprobe.d/all-net-blocklist.conf

    # replace depmod, for normal behavior
    mv /usr/sbin/depmod /usr/sbin/depmod.bak
    ln -sf /usr/bin/kmod /usr/sbin/depmod

    # rebulid dependencies for added network kernel drivers modules
    depmod -b /usr

    # enqueue hot fix for patch_bottom
    echo '/scripts/init-bottom/zzzz-hotfix-pxe' | tee -a /scripts/init-bottom/ORDER
}

patch_top
EOF
(( $? != 0 )) && return -4
sudo chmod +x "${TMP:?}/conf/conf.d/zzzz-hotfix-pxe"
(( $? != 0 )) && return -4
}

do_patch_bottom() {
[[ -e "${TMP:?}/scripts/init-bottom/" ]] || sudo mkdir -p "${TMP:?}/scripts/init-bottom/"
cat << EOF | sudo tee "${TMP:?}/scripts/init-bottom/zzzz-hotfix-pxe" &>/dev/null
#!/usr/bin/sh

patch_bottom()
{
    if ! [ -n "\$break" ]; then
        # hotfix-pxe for issue with network initialisation in tails
        local path_device
        for path_device in /sys/class/net/*; do
            local name_device
            name_device=\$(basename \$path_device)
            if [ "\$name_device" != "lo" ]; then
                # set network devices down
                ip link set \$name_device down

                local path_module
                path_module=\$(readlink \$path_device/device/driver/module)
                if [ -n "\$path_module" ]; then
                    # remove used network drivers
                    local name_module
                    name_module=\$(basename \$path_module)
                    modprobe -r \$name_module
                fi
            fi
        done
    fi
}

patch_bottom
EOF
(( $? != 0 )) && return -4
sudo chmod +x "${TMP:?}/scripts/init-bottom/zzzz-hotfix-pxe"
(( $? != 0 )) && return -4
}


do_initrd() {
# create an initrd image to overlay at boot time
sudo rm "${DST:?}"
cd "${TMP:?}"
(( $? != 0 )) && return -4
find . -mindepth 1 -print0 | cpio --null --create --verbose --format=newc \
    | sudo tee "${DST:?}" &>/dev/null
(( $? != 0 )) && return -4
cd -
}


do_cleanup() {
# clean up temporary files
sudo rm -rf "${TMP:?}"
(( $? != 0 )) && return -4
}


do_modules
do_patch_top
do_patch_bottom

do_initrd

do_cleanup


echo done.
