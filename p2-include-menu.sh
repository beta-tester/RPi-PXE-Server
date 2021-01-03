#!/bin/bash

##########################################################################
if [ -z "$script_dir" ]
then
    echo "do not run this script directly !"
    echo "this script is part of install-pxe-server-pass2.sh"
    exit -1
fi
##########################################################################


#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$ARCH_NETBOOT_X64/kernel" ]; then
    echo  -e "\e[36m    add $ARCH_NETBOOT_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    # INFO: https://www.archlinux.org/releng/netboot/
    LABEL $ARCH_NETBOOT_X64
        MENU LABEL Arch netboot x64
    #    KERNEL https://www.archlinux.org/static/netboot/ipxe.lkrn
        KERNEL $FILE_BASE$NFS_ETH0/$ARCH_NETBOOT_X64/kernel
        TEXT HELP
            Boot to Arch netboot x64
            User: root
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$BLACKARCH_X64/blackarch/boot/x86_64/vmlinuz-linux" ]; then
    echo  -e "\e[36m    add $BLACKARCH_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $BLACKARCH_X64
        MENU LABEL BlackArch x64
        KERNEL $FILE_BASE$NFS_ETH0/$BLACKARCH_X64/blackarch/boot/x86_64/vmlinuz-linux
        INITRD $FILE_BASE$NFS_ETH0/$BLACKARCH_X64/blackarch/boot/intel-ucode.img,$FILE_BASE$NFS_ETH0/$BLACKARCH_X64/blackarch/boot/amd-ucode.img,$FILE_BASE$NFS_ETH0/$BLACKARCH_X64/blackarch/boot/x86_64/initramfs-linux.img
        APPEND ro archisobasedir=blackarch archiso_nfs_srv=$IP_ETH0:$DST_NFS_ETH0/$BLACKARCH_X64 copytoram=n
        SYSAPPEND 3
        TEXT HELP
            Boot to BlackArch Linux full medium (x86_64, UEFI)
            User:  root, Password: blackarch
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$CLONEZILLA_X64/live/vmlinuz" ]; then
    echo  -e "\e[36m    add $CLONEZILLA_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $CLONEZILLA_X64
        MENU LABEL Clonezilla x64
        KERNEL $FILE_BASE$NFS_ETH0/$CLONEZILLA_X64/live/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$CLONEZILLA_X64/live/initrd.img
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$CLONEZILLA_X64 ro netboot=nfs boot=live config username=user hostname=clonezilla union=overlay components noswap edd=on nomodeset nodmraid ocs_live_run=ocs-live-general ocs_live_extra_param= ocs_live_batch=no net.ifnames=0 nosplash noprompt -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Clonezilla x64
            User: user, Password: live
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$CLONEZILLA_X86/live/vmlinuz" ]; then
    echo  -e "\e[36m    add $CLONEZILLA_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $CLONEZILLA_X86
        MENU LABEL Clonezilla x86
        KERNEL $FILE_BASE$NFS_ETH0/$CLONEZILLA_X86/live/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$CLONEZILLA_X86/live/initrd.img
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$CLONEZILLA_X86 ro netboot=nfs boot=live config username=user hostname=clonezilla union=overlay components noswap edd=on nomodeset nodmraid ocs_live_run=ocs-live-general ocs_live_extra_param= ocs_live_batch=no net.ifnames=0 nosplash noprompt -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Clonezilla x86
            User: user, Password: live
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DEBIAN_TESTING_X64/live/vmlinuz-$DEBIAN_TESTING_KVER-amd64" ]; then
    echo  -e "\e[36m    add $DEBIAN_TESTING_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DEBIAN_TESTING_X64
        MENU LABEL Debian x64 (testing)
        KERNEL $FILE_BASE$NFS_ETH0/$DEBIAN_TESTING_X64/live/vmlinuz-$DEBIAN_TESTING_KVER-amd64
        INITRD $FILE_BASE$NFS_ETH0/$DEBIAN_TESTING_X64/live/initrd.img-$DEBIAN_TESTING_KVER-amd64
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_TESTING_X64 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Debian x64 Live (testing)
            User: user, Password: live
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DEBIAN_X64/live/vmlinuz-$DEBIAN_KVER-amd64" ]; then
    echo  -e "\e[36m    add $DEBIAN_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DEBIAN_X64
        MENU LABEL Debian x64
        KERNEL $FILE_BASE$NFS_ETH0/$DEBIAN_X64/live/vmlinuz-$DEBIAN_KVER-amd64
        INITRD $FILE_BASE$NFS_ETH0/$DEBIAN_X64/live/initrd.img-$DEBIAN_KVER-amd64
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X64 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Debian x64 Live LXDE
            User: user, Password: live
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DEBIAN_X86/live/vmlinuz-$DEBIAN_KVER-686" ]; then
    echo  -e "\e[36m    add $DEBIAN_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DEBIAN_X86
        MENU LABEL Debian x86
        KERNEL $FILE_BASE$NFS_ETH0/$DEBIAN_X86/live/vmlinuz-$DEBIAN_KVER-686
        INITRD $FILE_BASE$NFS_ETH0/$DEBIAN_X86/live/initrd.img-$DEBIAN_KVER-686
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X86 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Debian x86 Live LXDE
            User: user, Password: live
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DEFT_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $DEFT_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DEFT_X64
        MENU LABEL DEFT x64
        KERNEL $FILE_BASE$NFS_ETH0/$DEFT_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$DEFT_X64/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEFT_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to DEFT x64 Live
            User: root, Password: toor
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DEFTZ_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $DEFTZ_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DEFTZ_X64
        MENU LABEL DEFT Zero x64
        KERNEL $FILE_BASE$NFS_ETH0/$DEFTZ_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$DEFTZ_X64/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEFTZ_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to DEFT Zero x64 Live
            User: root, Password: toor
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DEVUAN_X64/live/vmlinuz" ]; then
    echo  -e "\e[36m    add $DEVUAN_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DEVUAN_X64
        MENU LABEL Devuan x64
        KERNEL $FILE_BASE$NFS_ETH0/$DEVUAN_X64/live/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$DEVUAN_X64/live/initrd.img
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEVUAN_X64 ro netboot=nfs boot=live username=devuan config -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Devuan x64 Live
            User: devuan
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DEVUAN_X86/live/vmlinuz" ]; then
    echo  -e "\e[36m    add $DEVUAN_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DEVUAN_X86
        MENU LABEL Devuan x86
        KERNEL $FILE_BASE$NFS_ETH0/$DEVUAN_X86/live/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$DEVUAN_X86/live/initrd.img
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEVUAN_X86 ro netboot=nfs boot=live username=devuan config -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Devuan x86 Live
            User: devuan
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DRAGONOS_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $DRAGONOS_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DRAGONOS_X64
        MENU LABEL DragonOS x64
        KERNEL $FILE_BASE$NFS_ETH0/$DRAGONOS_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$DRAGONOS_X64/casper/initrd.gz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DRAGONOS_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to DragonOS x64 Live
            User: live
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$ESET_SYSRESCUE_X86/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $ESET_SYSRESCUE_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $ESET_SYSRESCUE_X86
        MENU LABEL ESET SysRescue Live
        KERNEL $FILE_BASE$NFS_ETH0/$ESET_SYSRESCUE_X86/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$ESET_SYSRESCUE_X86/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$ESET_SYSRESCUE_X86 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to ESET SysRescue Live
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$FEDORA_X64/isolinux/vmlinuz" ]; then
    echo  -e "\e[36m    add $FEDORA_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    ## INFO: http://people.redhat.com/harald/dracut.html#dracut.kernel
    ##       https://github.com/haraldh/dracut/blob/master/dracut.cmdline.7.asc
    ##       https://lukas.zapletalovi.com/2016/08/hidden-feature-of-fedora-24-live-pxe-boot.html
    LABEL $FEDORA_X64
        MENU LABEL Fedora x64
        KERNEL $FILE_BASE$NFS_ETH0/$FEDORA_X64/isolinux/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$FEDORA_X64/isolinux/initrd.img
        APPEND root=live:nfs://$IP_ETH0$DST_NFS_ETH0/$FEDORA_X64/LiveOS/squashfs.img ro rd.live.image rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 vga=794 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LOCALE
        TEXT HELP
            Boot to Fedora Workstation Live
            User: liveuser
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$GNURADIO_X64/casper/vmlinuz.efi" ]; then
    echo  -e "\e[36m    add $GNURADIO_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $GNURADIO_X64
        MENU LABEL GNU Radio x64
        KERNEL $FILE_BASE$NFS_ETH0/$GNURADIO_X64/casper/vmlinuz.efi
        INITRD $FILE_BASE$NFS_ETH0/$GNURADIO_X64/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$GNURADIO_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to GNU Radio x64 Live
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$KALI_X64/live/vmlinuz" ]; then
    echo  -e "\e[36m    add $KALI_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $KALI_X64
        MENU LABEL Kali x64
        KERNEL $FILE_BASE$NFS_ETH0/$KALI_X64/live/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$KALI_X64/live/initrd.img
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$KALI_X64 ro netboot=nfs boot=live noconfig=sudo username=kali hostname=kali -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Kali x64 Live
            User: kali, Password: kali
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$KASPERSKY_RESCUE_X86/boot/grub/k-x86_64" ]; then
    echo  -e "\e[36m    add $KASPERSKY_RESCUE_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $KASPERSKY_RESCUE_X86
        MENU LABEL Kaspersky Rescue Disk
        KERNEL $FILE_BASE$NFS_ETH0/$KASPERSKY_RESCUE_X86/boot/grub/k-x86
        INITRD $FILE_BASE$NFS_ETH0/$KASPERSKY_RESCUE_X86/boot/grub/initrd.xz
        APPEND netboot=nfs://$IP_ETH0:$DST_NFS_ETH0/$KASPERSKY_RESCUE_X86 ro dostartx -- lang=us setkmap=us
        TEXT HELP
            Boot to Kaspersky Rescue Disk
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$KNOPPIX_X86/boot/isolinux/linux" ]; then
    if ! [ -f "$DST_NFS_ETH0/$KNOPPIX_X86-miniroot-8.6.1.gz" ]; then
        echo  -e "\e[36m    download patch for $KNOPPIX_X86\e[0m";
        sudo wget --quiet -O $DST_NFS_ETH0/$KNOPPIX_X86-miniroot-8.6.1.gz https://github.com/beta-tester/RPi-PXE-Server/files/3932135/$KNOPPIX_X86-miniroot-8.6.1.gz
    fi
    if [ -f "$DST_NFS_ETH0/$KNOPPIX_X86-miniroot-8.6.1.gz" ]; then
        echo  -e "\e[36m    add $KNOPPIX_X86\e[0m";
        cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    ## INFO: https://github.com/beta-tester/RPi-PXE-Server/issues/27
    ## $ knoppix-terminalserver
    ## $ cp /tmp/tftproot/miniroot.gz  /srv/nfs/knoppix-x86-miniroot.gz
    LABEL $KNOPPIX_X86
        MENU LABEL Knoppix x86
        KERNEL $FILE_BASE$NFS_ETH0/$KNOPPIX_X86/boot/isolinux/linux
        INITRD $FILE_BASE$NFS_ETH0/knoppix-x86-miniroot-8.6.1.gz
        APPEND nfsdir=$IP_ETH0:$DST_NFS_ETH0/$KNOPPIX_X86 nodhcp ramdisk_size=100000 init=/sbin/init apm=power-off nomce loglevel=1 libata.force=noncq tz=localtime hpsa.hpsa_allow_any=1 BOOT_IMAGE=knoppix -- lang=de
        TEXT HELP
            Boot to Knoppix x86 Live
        ENDTEXT
EOF
    else
        echo  -e "\e[1;31m    failed $KNOPPIX_X86,\e[0m"
        echo  -e "\e[1;31m        please visit: https://github.com/beta-tester/RPi-PXE-Server/issues/27\e[0m";
    fi
fi
#========== END ==========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$LUBUNTU_DAILY_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $LUBUNTU_DAILY_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $LUBUNTU_DAILY_X64
        MENU LABEL lubuntu x64 Daily-Live
        KERNEL $FILE_BASE$NFS_ETH0/$LUBUNTU_DAILY_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$LUBUNTU_DAILY_X64/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$LUBUNTU_DAILY_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/lubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to lubuntu x64 Daily-Live
            User: lubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$LUBUNTU_LTS_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $LUBUNTU_LTS_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $LUBUNTU_LTS_X64
        MENU LABEL lubuntu LTS x64
        KERNEL $FILE_BASE$NFS_ETH0/$LUBUNTU_LTS_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$LUBUNTU_LTS_X64/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$LUBUNTU_LTS_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/lubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to lubuntu LTS x64 Live
            User: lubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$LUBUNTU_LTS_X86/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $LUBUNTU_LTS_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $LUBUNTU_LTS_X86
        MENU LABEL lubuntu LTS x86
        KERNEL $FILE_BASE$NFS_ETH0/$LUBUNTU_LTS_X86/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$LUBUNTU_LTS_X86/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$LUBUNTU_LTS_X86 ro netboot=nfs ip=dhcp file=/cdrom/preseed/lubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to lubuntu LTS x86 Live
            User: lubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$LUBUNTU_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $LUBUNTU_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $LUBUNTU_X64
        MENU LABEL lubuntu x64
        KERNEL $FILE_BASE$NFS_ETH0/$LUBUNTU_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$LUBUNTU_X64/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$LUBUNTU_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/lubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to lubuntu x64 Live
            User: lubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$LUBUNTU_X86/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $LUBUNTU_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $LUBUNTU_X86
        MENU LABEL lubuntu x86
        KERNEL $FILE_BASE$NFS_ETH0/$LUBUNTU_X86/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$LUBUNTU_X86/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$LUBUNTU_X86 ro netboot=nfs ip=dhcp file=/cdrom/preseed/lubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to lubuntu x86 Live
            User: lubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$MINT_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $MINT_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $MINT_X64
        MENU LABEL linux-mint x64
        KERNEL $FILE_BASE$NFS_ETH0/$MINT_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$MINT_X64/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$MINT_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/linuxmint.seed boot=casper systemd.mask=tmp.mount -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to linux-mint x64 Live
            User:
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$OPENSUSE_RESCUE_X64/boot/x86_64/loader/linux" ]; then
    echo  -e "\e[36m    add $OPENSUSE_RESCUE_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $OPENSUSE_RESCUE_X64
        MENU LABEL openSUSE Leap Rescue x64
        KERNEL $FILE_BASE$NFS_ETH0/$OPENSUSE_RESCUE_X64/boot/x86_64/loader/linux
        INITRD $FILE_BASE$NFS_ETH0/$OPENSUSE_RESCUE_X64/boot/x86_64/loader/initrd
        APPEND root=live:AOEINTERFACE=e0.1 rd.kiwi.live.pxe --
        TEXT HELP
            Boot to openSUSE Leap Rescue Live
            User: liveuser
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$OPENSUSE_X64/boot/x86_64/loader/linux" ]; then
    echo  -e "\e[36m    add $OPENSUSE_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $OPENSUSE_X64
        MENU LABEL openSUSE Leap x64
        KERNEL $FILE_BASE$NFS_ETH0/$OPENSUSE_X64/boot/x86_64/loader/linux
        INITRD $FILE_BASE$NFS_ETH0/$OPENSUSE_X64/boot/x86_64/loader/initrd
        APPEND root=live:AOEINTERFACE=e1.1 rd.kiwi.live.pxe --
        TEXT HELP
            Boot to openSUSE Leap Live
            User: liveuser
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$PARROT_FULL_X64/live/vmlinuz" ]; then
    echo  -e "\e[36m    add $PARROT_FULL_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $PARROT_FULL_X64
        MENU LABEL Parrot Full x64
        KERNEL $FILE_BASE$NFS_ETH0/$PARROT_FULL_X64/live/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$PARROT_FULL_X64/live/initrd.img
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PARROT_FULL_X64 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG pkeys=$CUSTOM_LANG setxkbmap=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Parrot Full x64 Live (Security)
            User: user, Password: live
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$PARROT_LITE_X64/live/vmlinuz" ]; then
    echo  -e "\e[36m    add $PARROT_LITE_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $PARROT_LITE_X64
        MENU LABEL Parrot Lite x64
        KERNEL $FILE_BASE$NFS_ETH0/$PARROT_LITE_X64/live/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$PARROT_LITE_X64/live/initrd.img
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PARROT_LITE_X64 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG pkeys=$CUSTOM_LANG setxkbmap=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Parrot Lite x64 Live (Home/Workstation)
            User: user, Password: live
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$PENTOO_BETA_X64/boot/pentoo" ]; then
    echo  -e "\e[36m    add $PENTOO_BETA_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $PENTOO_BETA_X64
        MENU LABEL Pentoo Beta x64
        KERNEL $FILE_BASE$NFS_ETH0/$PENTOO_BETA_X64/boot/pentoo
        INITRD $FILE_BASE$NFS_ETH0/$PENTOO_BETA_X64/boot/pentoo.igz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PENTOO_BETA_X64 ro real_root=/dev/nfs root=/dev/ram0 init=/linuxrc overlayfs looptype=squashfs loop=/image.squashfs cdroot nox secureconsole max_loop=256 dokeymap video=uvesafb:mtrr:3,ywrap,1024x768-16 console=tty0 scsi_mod.use_blk_mq=1 net.ifnames=0 ipv6.autoconf=0 --
        TEXT HELP
            Boot to Pentoo Beta x64 Live
            User: pentoo
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$PENTOO_X64/boot/pentoo" ]; then
    echo  -e "\e[36m    add $PENTOO_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $PENTOO_X64
        MENU LABEL Pentoo x64
        KERNEL $FILE_BASE$NFS_ETH0/$PENTOO_X64/boot/pentoo
        INITRD $FILE_BASE$NFS_ETH0/$PENTOO_X64/boot/pentoo.igz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PENTOO_X64 ro real_root=/dev/nfs root=/dev/ram0 init=/linuxrc overlayfs looptype=squashfs loop=/image.squashfs cdroot nox secureconsole max_loop=256 dokeymap video=uvesafb:mtrr:3,ywrap,1024x768-16 console=tty0 scsi_mod.use_blk_mq=1 net.ifnames=0 ipv6.autoconf=0 --
        TEXT HELP
            Boot to Pentoo x64 Live
            User: pentoo
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$RPDESKTOP_X86/live/vmlinuz2" ]; then
    echo  -e "\e[36m    add $RPDESKTOP_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $RPDESKTOP_X86
        MENU LABEL Raspberry Pi Desktop
        KERNEL $FILE_BASE$NFS_ETH0/$RPDESKTOP_X86/live/vmlinuz2
        INITRD $FILE_BASE$NFS_ETH0/$RPDESKTOP_X86/live/initrd2.img
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$RPDESKTOP_X86 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LOCALE keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
        TEXT HELP
            Boot to Raspberry Pi Desktop
            User: pi, Password: raspberry
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$SYSTEMRESCUE_X64/sysresccd/boot/x86_64/vmlinuz" ]; then
    echo  -e "\e[36m    add $SYSTEMRESCUE_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $SYSTEMRESCUE_X64
        MENU LABEL System Rescue x64
        KERNEL $FILE_BASE$NFS_ETH0/$SYSTEMRESCUE_X64/sysresccd/boot/x86_64/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$SYSTEMRESCUE_X64/sysresccd/boot/intel_ucode.img,$FILE_BASE$NFS_ETH0/$SYSTEMRESCUE_X64/sysresccd/boot/amd_ucode.img,$FILE_BASE$NFS_ETH0/$SYSTEMRESCUE_X64/sysresccd/boot/x86_64/sysresccd.img
        #APPEND archisobasedir=sysresccd archiso_nfs_srv=$IP_ETH0:$DST_NFS_ETH0/$SYSTEMRESCUE_X64
        APPEND archisobasedir=sysresccd archiso_http_srv=$FILE_BASE$NFS_ETH0/$SYSTEMRESCUE_X64/
        SYSAPPEND 3
        TEXT HELP
            Boot to System Rescue x64 Live
            User: root
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$TAILS_X64/live/vmlinuz" ]; then
    if ! [ -f "$DST_NFS_ETH0/$TAILS_X64-hotfix-pxe.cpio.xz" ]; then
        #echo  -e "\e[36m    download patch for $TAILS_X64\e[0m";
        #sudo wget --quiet -O $DST_NFS_ETH0/$TAILS_X64-hotfix-pxe.cpio.xz https://github.com/beta-tester/RPi-PXE-Server/files/?/$TAILS_X64-hotfix-pxe.cpio.xz
        :
    fi
    if [ -f "$DST_NFS_ETH0/$TAILS_X64-hotfix-pxe.cpio.xz" ]; then
        echo  -e "\e[36m    add $TAILS_X64\e[0m";
        cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    ## INFO: how to create $DST_NFS_ETH0/$TAILS_X64-hotfix-pxe.cpio.xz
    ##       see:
    ##         https://github.com/beta-tester/RPi-PXE-Server/issues/31
    ########################################
    LABEL $TAILS_X64
        MENU LABEL Tails x64
        KERNEL $FILE_BASE$NFS_ETH0/$TAILS_X64/live/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$TAILS_X64/live/initrd.img,$FILE_BASE$NFS_ETH0/$TAILS_X64-hotfix-pxe.cpio.xz
        APPEND fetch=$FILE_BASE$NFS_ETH0/$TAILS_X64/live/filesystem.squashfs ro boot=live config live-media=removable ipv6.disable=1 nopersistence noprompt block.events_dfl_poll_msecs=1000 noautologin module=Tails slab_nomerge slub_debug=FZP mce=0 vsyscall=none page_poison=1 init_on_alloc=1 init_on_free=1 mds=full,nosmt timezone=Etc/UTC -- keyboard-layouts=$CUSTOM_LANG
        TEXT HELP
            Boot to Tails x64 Live
        ENDTEXT
EOF
    else
        echo  -e "\e[1;31m    failed $TAILS_X64,\e[0m"
        echo  -e "\e[1;31m        please visit: https://github.com/beta-tester/RPi-PXE-Server/issues/31\e[0m";
    fi
fi
#========== END ==========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$TINYCORE_X64/boot/vmlinuz64" ]; then
    echo  -e "\e[36m    add $TINYCORE_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    # INFO: http://wiki.tinycorelinux.net/wiki:boot_options
    LABEL $TINYCORE_X64
        MENU LABEL tiny core x64
        KERNEL $FILE_BASE$NFS_ETH0/$TINYCORE_X64/boot/vmlinuz64
        INITRD $FILE_BASE$NFS_ETH0/$TINYCORE_X64/boot/corepure64.gz
        APPEND nfsmount=$IP_ETH0:$DST_NFS_ETH0/$TINYCORE_X64 tce=/mnt/nfs/cde waitusb=5 vga=791 loglevel=3 -- lang=en kmap=qwertz/de-latin1 noswap norestore
        #APPEND nfsmount=$IP_ETH0:$DST_NFS_ETH0/$TINYCORE_X64.rw tce=/mnt/nfs/cde waitusb=5 vga=791 loglevel=3 -- lang=en kmap=qwertz/de-latin1 noswap norestore
        #APPEND httplist=$IP_ETH0$DST_NFS_ETH0/tinycore-x64.xbase.lst vga=791 loglevel=3 -- lang=en kmap=qwertz/de-latin1 tz=Europe/Berlin noswap norestore settime showapps pause
        TEXT HELP
            Boot to tiny core x64
            User: tc
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$TINYCORE_X64/boot/vmlinuz64" ]; then
    echo  -e "\e[36m    add $TINYCORE_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    # INFO: http://wiki.tinycorelinux.net/wiki:boot_options
    LABEL $TINYCORE_X64 (ISO)
        MENU LABEL tiny core x64 (ISO)
        KERNEL memdisk
        APPEND iso
        INITRD $FILE_BASE$ISO/$TINYCORE_X64.iso
        TEXT HELP
            Boot to tiny core x64
            User: tc
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$TINYCORE_X86/boot/vmlinuz" ]; then
    echo  -e "\e[36m    add $TINYCORE_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    # INFO: http://wiki.tinycorelinux.net/wiki:boot_options
    LABEL $TINYCORE_X86
        MENU LABEL tiny core x86
        KERNEL $FILE_BASE$NFS_ETH0/$TINYCORE_X86/boot/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$TINYCORE_X86/boot/core.gz
        APPEND nfsmount=$IP_ETH0:$DST_NFS_ETH0/$TINYCORE_X86 tce=/mnt/nfs/cde waitusb=5 vga=791 loglevel=3 -- lang=en kmap=qwertz/de-latin1 noswap norestore
        #APPEND nfsmount=$IP_ETH0:$DST_NFS_ETH0/$TINYCORE_X86.rw tce=/mnt/nfs/cde waitusb=5 vga=791 loglevel=3 -- lang=en kmap=qwertz/de-latin1 noswap norestore
        TEXT HELP
            Boot to tiny core x86
            User: tc
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$UBUNTU_DAILY_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $UBUNTU_DAILY_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $UBUNTU_DAILY_X64
        MENU LABEL Ubuntu x64 Daily-Live
        KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_DAILY_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_DAILY_X64/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_DAILY_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to Ubuntu x64 Daily-Live
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$UBUNTU_FWTS/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $UBUNTU_FWTS\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    ## INFO: https://wiki.ubuntu.com/FirmwareTestSuite/
    ##       https://wiki.ubuntu.com/FirmwareTestSuite/Reference
    ##       http://fwts.ubuntu.com/fwts-live/?C=M;O=D
    LABEL $UBUNTU_FWTS
        MENU LABEL Ubuntu Live FirmwareTestSuite
        KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_FWTS/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_FWTS/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_FWTS ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper toram --
        TEXT HELP
            Boot to Ubuntu Live FirmwareTestSuite
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$UBUNTU_LTS_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $UBUNTU_LTS_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $UBUNTU_LTS_X64
        MENU LABEL Ubuntu LTS x64
        KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_LTS_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_LTS_X64/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to Ubuntu LTS x64 Live
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$UBUNTU_LTS_X86/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $UBUNTU_LTS_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $UBUNTU_LTS_X86
        MENU LABEL Ubuntu LTS x86
        KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_LTS_X86/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_LTS_X86/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X86 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to Ubuntu LTS x86 Live
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$UBUNTU_STUDIO_DAILY_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $UBUNTU_STUDIO_DAILY_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $UBUNTU_STUDIO_DAILY_X64
        MENU LABEL Ubuntu Studio x64 Daily-Live
        KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_STUDIO_DAILY_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_STUDIO_DAILY_X64/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_STUDIO_DAILY_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to Ubuntu Studio x64 Daily-Live
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$UBUNTU_STUDIO_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $UBUNTU_STUDIO_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $UBUNTU_STUDIO_X64
        MENU LABEL Ubuntu Studio x64
        KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_STUDIO_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_STUDIO_X64/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_STUDIO_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to Ubuntu Studio x64 Live
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$UBUNTU_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $UBUNTU_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $UBUNTU_X64
        MENU LABEL Ubuntu x64
        KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_X64/casper/initrd
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to Ubuntu x64 Live
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$UBUNTU_X86/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $UBUNTU_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $UBUNTU_X86
        MENU LABEL Ubuntu x86
        KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_X86/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_X86/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X86 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to Ubuntu x86 Live
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========



##########################################################################
#custom#

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DESINFECT_X86/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $DESINFECT_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DESINFECT_X86
        MENU LABEL desinfect x86
        KERNEL $FILE_BASE$NFS_ETH0/$DESINFECT_X86/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$DESINFECT_X86/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DESINFECT_X86 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 rmdns -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to ct desinfect x86
            User: desinfect
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$DESINFECT_X64/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $DESINFECT_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $DESINFECT_X64
        MENU LABEL desinfect x64
        KERNEL $FILE_BASE$NFS_ETH0/$DESINFECT_X64/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$DESINFECT_X64/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DESINFECT_X64 ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 rmdns -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to ct desinfect x64
            User: desinfect
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$UBUNTU_NONPAE/casper/vmlinuz" ]; then
    echo  -e "\e[36m    add $UBUNTU_NONPAE\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $UBUNTU_NONPAE
        MENU LABEL Ubuntu non-PAE x86
        KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_NONPAE/casper/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_NONPAE/casper/initrd.lz
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_NONPAE ro netboot=nfs ip=dhcp file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/locale=$CUSTOM_LANG_LOCALE console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
        TEXT HELP
            Boot to Ubuntu non-PAE x86 Live
            User: ubuntu
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_TFTP_ETH0/$1/pxeboot.n12" ]; then
    echo  -e "\e[36m    add $WIN_PE_X86 (PXE)\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $WIN_PE_X86-pxe
        MENU LABEL Windows PE x86 (PXE)
        PXE pxeboot.n12
        TEXT HELP
            Boot to Windows PE 32bit
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_ISO/$WIN_PE_X86.iso" ]; then
    echo  -e "\e[36m    add $WIN_PE_X86 (ISO)\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $WIN_PE_X86-iso
        MENU LABEL Windows PE x86 (ISO)
        KERNEL memdisk
        APPEND iso raw
        INITRD $FILE_BASE$ISO/$WIN_PE_X86.iso
        TEXT HELP
            Boot to Windows PE 32bit ISO ~400MB
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_TFTP_ETH0/$1/wimboot" ] \
&& [ -f "$DST_NFS_ETH0/$WIN_PE_X86/sources/boot.wim" ]; then
    echo  -e "\e[36m    add $WIN_PE_X86 (WIM)\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $WIN_PE_X86-wim
        MENU LABEL Windows PE x86 (WIM)
        COM32 linux.c32 wimboot
        APPEND initrdfile=$FILE_BASE$NFS_ETH0/$WIN_PE_X86/Boot/BCD,$FILE_BASE$NFS_ETH0/$WIN_PE_X86/Boot/boot.sdi,$FILE_BASE$NFS_ETH0/$WIN_PE_X86/sources/boot.wim
        TEXT HELP
            Boot to Windows PE 32bit
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_TFTP_ETH0/$1/pxeboot.n12" ]; then
    echo  -e "\e[36m    add $WIN_PE_X64 (PXE)\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $WIN_PE_X64-pxe
        MENU LABEL Windows PE x64 (PXE)
        PXE pxeboot.n12
        TEXT HELP
            Boot to Windows PE 64bit
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_ISO/$WIN_PE_X64.iso" ]; then
    echo  -e "\e[36m    add $WIN_PE_X64 (ISO)\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $WIN_PE_X64-iso
        MENU LABEL Windows PE x64 (ISO)
        KERNEL memdisk
        APPEND iso raw
        INITRD $FILE_BASE$ISO/$WIN_PE_X64.iso
        TEXT HELP
            Boot to Windows PE 64bit ISO ~400MB
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_TFTP_ETH0/$1/wimboot" ] \
&& [ -f "$DST_NFS_ETH0/$WIN_PE_X64/sources/boot.wim" ]; then
    echo  -e "\e[36m    add $WIN_PE_X64 (WIM)\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    LABEL $WIN_PE_X64-wim
        MENU LABEL Windows PE x64 (WIM)
        COM64 linux.c64 wimboot
        APPEND initrdfile=$FILE_BASE$NFS_ETH0/$WIN_PE_X64/Boot/BCD,$FILE_BASE$NFS_ETH0/$WIN_PE_X64/Boot/boot.sdi,$FILE_BASE$NFS_ETH0/$WIN_PE_X64/sources/boot.wim
        TEXT HELP
            Boot to Windows PE 64bit
        ENDTEXT
EOF
fi
#=========== END ===========



##########################################################################
#broken#

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$ANDROID_X86/kernel" ]; then
    echo  -e "\e[36m    add $ANDROID_X86\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    ## NOT WORKING
    LABEL $ANDROID_X86
        MENU LABEL Android x86 (broken)
        KERNEL $FILE_BASE$NFS_ETH0/$ANDROID_X86/kernel
        INITRD $FILE_BASE$NFS_ETH0/$ANDROID_X86/initrd.img
        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$ANDROID_X86 ro netboot=nfs root=/dev/ram0 androidboot.selinux=permissive SRC= DATA=
        TEXT HELP
            Boot to Android x86 Live
            User: root
        ENDTEXT
EOF
fi
#=========== END ===========

#========== BEGIN ==========
if [ -f "$FILE_MENU" ] \
&& [ -f "$DST_NFS_ETH0/$CENTOS_X64/isolinux/vmlinuz" ]; then
    echo  -e "\e[36m    add $CENTOS_X64\e[0m";
    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null
    ########################################
    ## NOT WORKING
    ## INFO: http://people.redhat.com/harald/dracut.html#dracut.kernel
    ##       https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/chap-installation-server-setup
    ##       https://github.com/haraldh/dracut/blob/master/dracut.cmdline.7.asc
    LABEL $CENTOS_X64
        MENU LABEL CentOS x64 (broken)
        KERNEL $FILE_BASE$NFS_ETH0/$CENTOS_X64/isolinux/vmlinuz
        INITRD $FILE_BASE$NFS_ETH0/$CENTOS_X64/isolinux/initrd.img
        #APPEND root=live:nfs:$IP_ETH0$DST_NFS_ETH0/$CENTOS_X64 ro rootfstype=auto rd.live.image rhgb rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 rd.shell rd.break console=tty0 loglevel=7 vga=794 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LOCALE

    # dracut: FATAL: Don't know how to handle 'root=live:nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64';
        #APPEND root=live:nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64 ro root-path=/LiveOS/squashfs.img rootfstype=squashfs rd.live.image rd.live.ram=1 rd.live.overlay=none rd.luks=0 rd.md=0 rd.dm=0 vga=794 rd.shell log_buf_len=1M rd.retry=10 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LOCALE

    # dracut: FATAL: Don't know how to handle 'root=live:nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64/LiveOS/squashfs.img';
        #APPEND root=live:nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64/LiveOS/squashfs.img ro rootfstype=squashfs rd.live.image rd.live.ram=1 rd.live.overlay=none rd.luks=0 rd.md=0 rd.dm=0 vga=794 rd.shell log_buf_len=1M rd.retry=10 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LOCALE

    # mount.nfs: mountpoint /sysroot is not a directory
        #APPEND root=nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64/LiveOS/squashfs.img ro root-path=/LiveOS/squashfs.img rootfstype=squashfs rd.live.image rd.live.ram=1 rd.live.overlay=none rd.luks=0 rd.md=0 rd.dm=0 vga=794 rd.shell log_buf_len=1M rd.retry=10 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LOCALE

    # Warning: Could not boot.
        # Warning: /dev/mapper/live-rw does not exist
        # Starting Dracut Emergency Shell
        APPEND root=nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64 ro root-path=/LiveOS/squashfs.img rootfstype=squashfs rd.live.image rd.live.ram=1 rd.live.overlay=none rd.luks=0 rd.md=0 rd.dm=0 vga=794 rd.shell log_buf_len=1M rd.retry=10 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LOCALE

        TEXT HELP
            Boot to CentOS LiveGNOME
            User: liveuser
        ENDTEXT
EOF
fi
#========== END ==========
