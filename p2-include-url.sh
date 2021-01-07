#!/bin/bash

##########################################################################
if [ -z "$script_dir" ]
then
    echo "do not run this script directly !"
    echo "this script is part of install-pxe-server-pass2.sh"
    exit -1
fi
##########################################################################

# v 2021-01-07

# check broken url
# for i in $(grep [A-Z]=http ~/RPi-PXE-Server/p2-include-url.sh | sed s/^.*http/http/g); do wget --quiet --timeout=5 --spider $i && echo Ok = $i || echo failed $? = $i; done

##########################################################################
# winpe                https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
#                      https://www.heise.de/ct/artikel/c-t-Notfall-Windows-2020-4514169.html
#                      https://github.com/pebakery/pebakery
# arch                 https://www.archlinux.org/download/
# blackarch            https://blackarch.org/
# fedora               https://getfedora.org/en/workstation/download/
# ubuntu               https://releases.ubuntu.com/
#                      https://cdimage.ubuntu.com/ubuntu/releases/
#                      https://cdimage.ubuntu.com/daily-live/pending/
# ubuntu studio        https://cdimage.ubuntu.com/ubuntustudio/releases/
#                      https://cdimage.ubuntu.com/ubuntustudio/dvd/pending/
# lubuntu              https://cdimage.ubuntu.com/lubuntu/releases/
#                      https://cdimage.ubuntu.com/lubuntu/daily-live/pending/
# debian               https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/
#                      https://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/
# devuan               https://files.devuan.org/devuan_beowulf/desktop-live/
# gnuradio             https://wiki.gnuradio.org/index.php/GNU_Radio_Live_SDR_Environment
#                      http://eu2-dist.gnuradio.org/
# parrotsec            https://cdimage.parrotsec.org/parrot/iso/
# kali                 https://cdimage.kali.org/kali-images/current/
#                      https://cdimage.kali.org/kali-images/kali-weekly/
# pentoo               https://www.pentoo.ch/isos/latest-iso-symlinks/
# deft                 http://www.deftlinux.net/
# clonezilla           https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/
# system rescue cd     https://sourceforge.net/projects/systemrescuecd/files/sysresccd-x86/
#                      https://system-rescue-cd.org/
# tiny core            http://tinycorelinux.net/downloads.html
# rpdesktop            https://downloads.raspberrypi.org/rpd_x86/images/?C=M;O=D
# gentoo               https://www.gentoo.org/downloads/
#                      http://distfiles.gentoo.org/releases/amd64/
#                      http://distfiles.gentoo.org/releases/x86/
# opensuse             https://download.opensuse.org/distribution/openSUSE-current/live/
#                      https://download.opensuse.org/tumbleweed/iso/?C=M;O=D
# centos               https://www.centos.org/download/
# tail                 https://tails.boum.org/install/download/
# knoppix              https://www.knopper.net/knoppix-mirrors/index-en.html
# kaspersky            https://www.kaspersky.com/downloads/thank-you/free-rescue-disk
# bitdefender          https://download.bitdefender.com/rescue_cd/latest/
#                      Bitdefender Rescue CD reached End of Life on 2019-08-01
#                        https://www.bitdefender.com/consumer/support/answer/10131/
# ESET SysRescue Live  https://www.eset.com/int/download-utilities/#content-c10295
# linuxmint            https://www.linuxmint.com/download.php
#                      https://mirrors.edge.kernel.org/linuxmint/stable/
# android x86          https://osdn.net/projects/android-x86/
# rpi-raspbian         https://downloads.raspberrypi.org/raspios_armhf/images/
# piCore               http://tinycorelinux.net/9.x/armv6/releases/RPi/
#                      http://tinycorelinux.net/9.x/armv7/releases/RPi/


##########################################################################
##########################################################################
## url to iso images, with LiveDVD systems
## note:
##  update the url, if iso is outdated
##########################################################################
##########################################################################
ARCH_NETBOOT_X64=arch-netboot-x64
ARCH_NETBOOT_X64_URL=https://www.archlinux.org/static/netboot/ipxe.lkrn


CLONEZILLA_X64=clonezilla-x64
CLONEZILLA_X64_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.7.0-10/clonezilla-live-2.7.0-10-amd64.iso
CLONEZILLA_X86=clonezilla-x86
CLONEZILLA_X86_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.7.0-10/clonezilla-live-2.7.0-10-i686.iso


BLACKARCH_X64=blackarch-x64
BLACKARCH_X64_URL=https://ftp.halifax.rwth-aachen.de/blackarch/iso/blackarch-linux-full-2020.12.01-x86_64.iso


DEBIAN_KVER=4.19.0-13
DEBIAN_X64=debian-x64
DEBIAN_X64_URL=https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-10.7.0-amd64-cinnamon.iso
DEBIAN_X64_SUM=https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/SHA256SUMS
DEBIAN_X64_SUM_TYPE=sha256

DEBIAN_X86=debian-x86
DEBIAN_X86_URL=https://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/debian-live-10.7.0-i386-cinnamon.iso
DEBIAN_X86_SUM=https://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/SHA256SUMS
DEBIAN_X86_SUM_TYPE=sha256


DEFT_X64=deft-x64
DEFT_X64_URL=https://na.mirror.garr.it/mirrors/deft/iso/deft-8.2.iso
DEFT_X64_SUM=https://na.mirror.garr.it/mirrors/deft/md5.txt
DEFT_X64_SUM_TYPE=md5

DEFTZ_X64=deftz-x64
DEFTZ_X64_URL=https://na.mirror.garr.it/mirrors/deft/zero/deftZ-2018-2.iso
DEFTZ_X64_SUM=https://na.mirror.garr.it/mirrors/deft/zero/deftZ-2018-2.iso.md5
DEFTZ_X64_SUM_TYPE=md5


DEVUAN_X64=devuan-x64
DEVUAN_X64_URL=https://files.devuan.org/devuan_beowulf/desktop-live/devuan_beowulf_3.0.0_amd64_desktop-live.iso
DEVUAN_X64_SUM=https://files.devuan.org/devuan_beowulf/desktop-live/SHA256SUMS.txt
DEVUAN_X64_SUM_TYPE=sha256

DEVUAN_X86=devuan-x86
DEVUAN_X86_URL=https://files.devuan.org/devuan_beowulf/desktop-live/devuan_beowulf_3.0.0_i386_desktop-live.iso
DEVUAN_X86_SUM=https://files.devuan.org/devuan_beowulf/desktop-live/SHA256SUMS.txt
DEVUAN_X86_SUM_TYPE=sha256


DRAGONOS_X64=dragonos-x64
DRAGONOS_X64_URL=https://downloads.sourceforge.net/project/dragonos-focal/DragonOS_Focal_PublicR9.iso


ESET_SYSRESCUE_X86=eset-rescue-x86
ESET_SYSRESCUE_X86_URL=https://download.eset.com/com/eset/tools/recovery/rescue_cd/latest/eset_sysrescue_live_enu.iso


FEDORA_X64=fedora-x64
FEDORA_X64_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/33/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-33-1.2.iso
FEDORA_X64_SUM=https://download.fedoraproject.org/pub/fedora/linux/releases/33/Workstation/x86_64/iso/Fedora-Workstation-33-1.2-x86_64-CHECKSUM
FEDORA_X64_SUM_TYPE=sha256


GNURADIO_X64=gnuradio-x64
GNURADIO_X64_URL=http://eu2-dist.gnuradio.org/ubuntu-16.04.2-desktop-amd64-gnuradio-3.7.11.iso


KALI_X64=kali-x64
KALI_X64_URL=https://cdimage.kali.org/current/kali-linux-2020.4-live-amd64.iso
KALI_X64_SUM=https://cdimage.kali.org/current/SHA256SUMS
KALI_X64_SUM_TYPE=sha256


KASPERSKY_RESCUE_X86=kaspersky-rescue-x86
KASPERSKY_RESCUE_X86_URL=https://rescuedisk.s.kaspersky-labs.com/updatable/2018/krd.iso


KNOPPIX_X86=knoppix-x86
KNOPPIX_X86_URL=https://ftp.gwdg.de/pub/linux/knoppix/dvd/KNOPPIX_V8.6.1-2019-10-14-DE.iso
KNOPPIX_X86_SUM=https://ftp.gwdg.de/pub/linux/knoppix/dvd/KNOPPIX_V8.6.1-2019-10-14-DE.iso.sha256
KNOPPIX_X86_SUM_TYPE=sha256


LUBUNTU_DAILY_X64=lubuntu-daily-x64
LUBUNTU_DAILY_X64_URL=https://cdimage.ubuntu.com/lubuntu/daily-live/pending/hirsute-desktop-amd64.iso
LUBUNTU_DAILY_X64_SUM=https://cdimage.ubuntu.com/lubuntu/daily-live/pending/SHA256SUMS
LUBUNTU_DAILY_X64_SUM_TYPE=sha256

LUBUNTU_LTS_X64=lubuntu-lts-x64
LUBUNTU_LTS_X64_URL=https://cdimage.ubuntu.com/lubuntu/releases/20.04/release/lubuntu-20.04.1-desktop-amd64.iso
LUBUNTU_LTS_X64_SUM=https://cdimage.ubuntu.com/lubuntu/releases/20.04/release/SHA256SUMS
LUBUNTU_LTS_X64_SUM_TYPE=sha256

LUBUNTU_X64=lubuntu-x64
LUBUNTU_X64_URL=https://cdimage.ubuntu.com/lubuntu/releases/20.10/release/lubuntu-20.10-desktop-amd64.iso
LUBUNTU_X64_SUM=https://cdimage.ubuntu.com/lubuntu/releases/20.10/release/SHA256SUMS
LUBUNTU_X64_SUM_TYPE=sha256

LUBUNTU_LTS_X86=lubuntu-lts-x86
LUBUNTU_LTS_X86_URL=https://cdimage.ubuntu.com/lubuntu/releases/18.04/release/lubuntu-18.04.5-desktop-i386.iso
LUBUNTU_LTS_X86_SUM=https://cdimage.ubuntu.com/lubuntu/releases/18.04/release/SHA256SUMS
LUBUNTU_LTS_X86_SUM_TYPE=sha256


MINT_X64=mint-x64
MINT_X64_URL=https://mirrors.edge.kernel.org/linuxmint/stable/20.1/linuxmint-20.1-cinnamon-64bit.iso
MINT_X64_SUM=https://mirrors.edge.kernel.org/linuxmint/stable/20.1/sha256sum.txt
MINT_X64_SUM_TYPE=sha256


OPENSUSE_RESCUE_X64=opensuse-rescue-x64
OPENSUSE_RESCUE_X64_URL=https://download.opensuse.org/distribution/openSUSE-current/live/openSUSE-Leap-15.2-Rescue-CD-x86_64-Media.iso
OPENSUSE_RESCUE_X64_SUM=https://download.opensuse.org/distribution/openSUSE-current/live/openSUSE-Leap-15.2-Rescue-CD-x86_64-Media.iso.sha256
OPENSUSE_RESCUE_X64_SUM_TYPE=sha256

OPENSUSE_X64=opensuse-x64
OPENSUSE_X64_URL=https://download.opensuse.org/distribution/openSUSE-current/live/openSUSE-Leap-15.2-KDE-Live-x86_64-Media.iso
OPENSUSE_X64_SUM=https://download.opensuse.org/distribution/openSUSE-current/live/openSUSE-Leap-15.2-KDE-Live-x86_64-Media.iso.sha256
OPENSUSE_X64_SUM_TYPE=sha256


PARROT_FULL_X64=parrot-full-x64
PARROT_FULL_X64_URL=https://cdimage.parrotsec.org/parrot/iso/current/Parrot-security-4.10_amd64.iso
PARROT_FULL_X64_SUM=https://cdimage.parrotsec.org/parrot/iso/current/signed-hashes.txt
PARROT_FULL_X64_SUM_TYPE=sha256

PARROT_LITE_X64=parrot-lite-x64
PARROT_LITE_X64_URL=https://cdimage.parrotsec.org/parrot/iso/current/Parrot-home-4.10_amd64.iso
PARROT_LITE_X64_SUM=https://cdimage.parrotsec.org/parrot/iso/current/signed-hashes.txt
PARROT_LITE_X64_SUM_TYPE=sha256


PENTOO_BETA_X64=pentoo-beta-x64
PENTOO_BETA_X64_URL=https://pentoo.ch/isos/latest-iso-symlinks/Daily/pentoo-full-daily-amd64-hardened-latest.iso

PENTOO_X64=pentoo-x64
PENTOO_X64_URL=https://pentoo.ch/isos/latest-iso-symlinks/Daily/pentoo-full-daily-amd64-hardened-latest.iso


RPDESKTOP_X86=rpdesktop-x86
RPDESKTOP_X86_URL=https://downloads.raspberrypi.org/rpd_x86_latest
RPDESKTOP_X86_SUM=https://www.raspberrypi.org/downloads/raspberry-pi-desktop/
RPDESKTOP_X86_SUM_TYPE=sha256


SYSTEMRESCUE_X64=systemrescue-x64
SYSTEMRESCUE_X64_URL=https://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/7.01/systemrescue-7.01-amd64.iso

TAILS_X64=tails-x64
TAILS_X64_URL=https://mirrors.edge.kernel.org/tails/stable/tails-amd64-4.14/tails-amd64-4.14.iso
TAILS_X64_SUM=https://mirrors.edge.kernel.org/tails/stable/tails-amd64-4.14/tails-amd64-4.14.iso.sig
TAILS_X64_SUM_TYPE=pgp


TINYCORE_X64=tinycore-x64
TINYCORE_X64_URL=http://tinycorelinux.net/11.x/x86_64/release/TinyCorePure64-current.iso
TINYCORE_X64_SUM=http://tinycorelinux.net/11.x/x86_64/release/TinyCorePure64-current.iso.md5.txt
TINYCORE_X64_SUM_TYPE=md5

TINYCORE_X86=tinycore-x86
TINYCORE_X86_URL=http://tinycorelinux.net/11.x/x86/release/TinyCore-current.iso
TINYCORE_X86_SUM=http://tinycorelinux.net/11.x/x86/release/TinyCore-current.iso.md5.txt
TINYCORE_X86_SUM_TYPE=md5


UBUNTU_DAILY_X64=ubuntu-daily-x64
UBUNTU_DAILY_X64_URL=https://cdimage.ubuntu.com/daily-live/pending/hirsute-desktop-amd64.iso
UBUNTU_DAILY_X64_SUM=https://cdimage.ubuntu.com/daily-live/pending/SHA256SUMS
UBUNTU_DAILY_X64_SUM_TYPE=sha256

UBUNTU_FWTS=ubuntu-fwts
UBUNTU_FWTS_URL=http://fwts.ubuntu.com/fwts-live/fwts-live-20.07.00.img.xz
UBUNTU_FWTS_SUM=http://fwts.ubuntu.com/fwts-live/SHA256SUM
UBUNTU_FWTS_SUM_TYPE=sha256

UBUNTU_LTS_X64=ubuntu-lts-x64
UBUNTU_LTS_X64_URL=https://releases.ubuntu.com/20.04/ubuntu-20.04.1-desktop-amd64.iso
UBUNTU_LTS_X64_SUM=https://releases.ubuntu.com/20.04/SHA256SUMS
UBUNTU_LTS_X64_SUM_TYPE=sha256

UBUNTU_STUDIO_DAILY_X64=ubuntu-studio-daily-x64
UBUNTU_STUDIO_DAILY_X64_URL=https://cdimage.ubuntu.com/ubuntustudio/dvd/pending/hirsute-dvd-amd64.iso
UBUNTU_STUDIO_DAILY_X64_SUM=https://cdimage.ubuntu.com/ubuntustudio/dvd/pending/SHA256SUMS
UBUNTU_STUDIO_DAILY_X64_SUM_TYPE=sha256

UBUNTU_STUDIO_X64=ubuntu-studio-x64
UBUNTU_STUDIO_X64_URL=https://cdimage.ubuntu.com/ubuntustudio/releases/20.10/release/ubuntustudio-20.10-dvd-amd64.iso
UBUNTU_STUDIO_X64_SUM=https://cdimage.ubuntu.com/ubuntustudio/releases/20.10/release/SHA256SUMS
UBUNTU_STUDIO_X64_SUM_TYPE=sha256

UBUNTU_X64=ubuntu-x64
UBUNTU_X64_URL=https://releases.ubuntu.com/20.10/ubuntu-20.10-desktop-amd64.iso
UBUNTU_X64_SUM=https://releases.ubuntu.com/20.10/SHA256SUMS
UBUNTU_X64_SUM_TYPE=sha256

UBUNTU_LTS_X86=ubuntu-lts-x86
UBUNTU_LTS_X86_URL=https://releases.ubuntu.com/16.04/ubuntu-16.04.6-desktop-i386.iso
UBUNTU_LTS_X86_SUM=https://releases.ubuntu.com/16.04/SHA256SUMS
UBUNTU_LTS_X86_SUM_TYPE=sha256


#custom#
DESINFECT_X64=desinfect-x64
DESINFECT_X64_URL=

DESINFECT_X86=desinfect-x86
DESINFECT_X86_URL=


UBUNTU_NONPAE=ubuntu-nonpae
UBUNTU_NONPAE_URL=


WIN_PE_X86=win-pe-x86
WIN_PE_X86_URL=

WIN_PE_X64=win-pe-x64
WIN_PE_X64_URL=


#broken#
ANDROID_X86=android-x86
ANDROID_X86_URL=https://dotsrc.dl.osdn.net/osdn/android-x86/71931/android-x86_64-9.0-r2.iso


CENTOS_X64=centos-x64
CENTOS_X64_URL=https://mirrors.edge.kernel.org/centos/7/isos/x86_64/CentOS-7-x86_64-LiveGNOME-2003.iso
CENTOS_X64_SUM=https://mirrors.edge.kernel.org/centos/7/isos/x86_64/sha256sum.txt
CENTOS_X64_SUM_TYPE=sha256


##########################################################################
##########################################################################
## url to zip files,
##  that contains disk images
##  for raspbarry pi 3 pxe network booting
## note:
##  update the url, if disk image is outdated
##########################################################################
##########################################################################
PI_CORE=pi-core
PI_CORE_URL=http://tinycorelinux.net/9.x/armv7/releases/RPi/piCore-9.0.3.zip


RPD_BASIC=rpi-raspbian-basic
RPD_BASIC_URL=https://downloads.raspberrypi.org/raspios_armhf_latest
RPD_BASIC_SUM=https://www.raspberrypi.org/downloads/raspberry-pi-os/
RPD_BASIC_SUM_TYPE=sha256

RPD_FULL=rpi-raspbian-full
RPD_FULL_URL=https://downloads.raspberrypi.org/raspios_full_armhf_latest
RPD_FULL_SUM=https://www.raspberrypi.org/downloads/raspberry-pi-os/
RPD_FULL_SUM_TYPE=sha256

RPD_LITE=rpi-raspbian-lite
RPD_LITE_URL=https://downloads.raspberrypi.org/raspios_lite_armhf_latest
RPD_LITE_SUM=https://www.raspberrypi.org/downloads/raspberry-pi-os/
RPD_LITE_SUM_TYPE=sha256


##########################################################################
