#!/bin/bash

##########################################################################
# known issues:
#


script_dir=$(dirname "$BASH_SOURCE")

BACKUP_FILE=backup.tar.xz


######################################################################
echo -e "\e[36msetup variables\e[0m";


##########################################################################
##########################################################################
## variables, you have to customize
## e.g.:
##  RPI_SN0 : serial number
##            of the raspberry pi 3 for network booting
##  and other variables...
##########################################################################
##########################################################################
. "$script_dir/p2-include-var.sh"

echo
echo -e "$INTERFACE_ETH0 \e[36mis used as primary networkadapter for PXE\e[0m";
echo -e "$IP_ETH0 \e[36mis used as primary IP address for PXE\e[0m";
echo -e "$RPI_SN0 \e[36mis used as SN for RPi3 network booting\e[0m";
echo

if [ -z $IP_ETH0 ]; then
    echo -e "\e[1;31mIP address not found. please check your ethernet cable.\e[0m";
    exit 1
fi

if [ -z $IP_ETH0_ROUTER ]; then
    echo -e "\e[1;31mrouter IP address not found. please check your router settings.\e[0m";
    exit 1
fi

sudo umount -f $SRC_MOUNT &>/dev/null;
sudo mount $SRC_MOUNT &>/dev/null;

##########################################################################
##########################################################################
## url to iso images, with LiveDVD systems
## note:
##  update the url, if iso is outdated
##########################################################################
##########################################################################
. "$script_dir/p2-include-url.sh"




##########################################################################
handle_dhcpcd() {
    echo -e "\e[32mhandle_dhcpcd()\e[0m";

    ######################################################################
    echo -e "\e[36m    a stretch or newer OS detected\e[0m";
    ##################################################################
    grep -q mod_install_server /etc/dhcpcd.conf || {
        echo -e "\e[36m    setup dhcpcd.conf\e[0m";
        tar -ravf $BACKUP_FILE -C / etc/dhcpcd.conf
        cat << EOF | sudo tee -a /etc/dhcpcd.conf &>/dev/null

########################################
## mod_install_server
interface $INTERFACE_ETH0
    slaac private
    static ip_address=$IP_ETH0/24
    static ip6_address=fd80::$IP_ETH0/120
    static routers=$IP_ETH0_ROUTER
    static domain_name_servers=$IP_ETH0_ROUTER 8.8.8.8 fd51:42f8:caae:d92e::1
EOF
    sudo systemctl daemon-reload;
    sudo systemctl restart dhcpcd.service;
    }
}


##########################################################################
handle_dnsmasq() {
    echo -e "\e[32mhandle_dnsmasq()\e[0m";

    ######################################################################
    [ -f /etc/dnsmasq.d/pxe-server ] || {
        echo -e "\e[36m    setup dnsmasq for pxe\e[0m";
        tar -ravf $BACKUP_FILE -C / etc/dnsmasq.d/10-pxe-server
        cat << EOF | sudo tee /etc/dnsmasq.d/10-pxe-server &>/dev/null
########################################
#/etc/dnsmasq.d/pxeboot
## mod_install_server

log-dhcp
#log-queries

# for local resolve
interface=lo

# interface selection
interface=$INTERFACE_ETH0

#
bind-dynamic

##########
# TFTP_ETH0 (enabled)
enable-tftp=$INTERFACE_ETH0
#tftp-lowercase
tftp-root=$DST_TFTP_ETH0/, $INTERFACE_ETH0
dhcp-option=tag:$INTERFACE_ETH0, option:tftp-server, 0.0.0.0

##########
# Time Server
dhcp-option=tag:$INTERFACE_ETH0,  option:ntp-server,  0.0.0.0
dhcp-option=tag:$INTERFACE_ETH0,  option6:ntp-server, [::]

##########
# DHCP
log-dhcp
#enable-ra

# block NETGEAR managed switch
dhcp-mac=set:block, 28:c6:8e:*:*:*

# static IP
#dhcp-host=set:known_128,  08:08:08:08:08:08, 192.168.1.128,  [fd80::192.168.1.128],  infinite
#dhcp-host=set:known_129,  client_acb,        192.168.1.129,  [fd80::192.168.1.129],  infinite

# dynamic IP
dhcp-range=tag:$INTERFACE_ETH0,  tag:!block,  fd80::$IP_ETH0_START, fd80::$IP_ETH0_END, 120, 1h
dhcp-range=tag:$INTERFACE_ETH0,  tag:!block,  $IP_ETH0_START, $IP_ETH0_END, 255.255.255.0, 1h

##########
# DNS (enabled)
port=53
#log-queries
dns-loop-detect
stop-dns-rebind
bogus-priv
domain-needed
dhcp-option=tag:$INTERFACE_ETH0, option:netbios-ns, 0.0.0.0
dhcp-option=tag:$INTERFACE_ETH0, option:netbios-dd, 0.0.0.0

# PXE (enabled)
# warning: unfortunately, a RPi3 identifies itself as of architecture x86PC (x86PC=0)
dhcp-mac=set:IS_RPI3,B8:27:EB:*:*:*
dhcp-mac=set:IS_RPI4,DC:A6:32:*:*:*
dhcp-match=set:ARCH_0, option:client-arch, 0

# test if it is a RPi or a regular x86PC
tag-if=set:ARM_RPI, tag:ARCH_0, tag:IS_RPI3
tag-if=set:ARM_RPI, tag:ARCH_0, tag:IS_RPI4

##########
# RPi 3
pxe-service=tag:IS_RPI3,0, "Raspberry Pi Boot   ", bootcode.bin
dhcp-boot=tag:IS_RPI3, bootcode.bin

##########
# PXE Linux
dhcp-match=set:x86_UEFI, option:client-arch, 6
dhcp-match=set:x64_UEFI, option:client-arch, 7
dhcp-match=set:x64_UEFI, option:client-arch, 9
tag-if=set:x86_BIOS, tag:ARCH_0, tag:!ARM_RPI
#pxe-service=tag:x86_BIOS,x86PC, "PXE Boot Menu (BIOS 00:00)", $DST_PXE_BIOS/lpxelinux
#pxe-service=6, "PXE Boot Menu (UEFI 00:06)", $DST_PXE_EFI32/bootia32.efi
#pxe-service=tag:x86-64_EFI, "PXE Boot Menu (UEFI 00:07)", $DST_PXE_EFI64/bootx64.efi
#pxe-service=9, "PXE Boot Menu (UEFI 00:09)", $DST_PXE_EFI64/bootx64.efi
dhcp-boot=tag:x86_BIOS, $DST_PXE_BIOS/lpxelinux.0
dhcp-boot=tag:x86_UEFI, $DST_PXE_EFI32/bootia32.efi
dhcp-boot=tag:x64_UEFI, $DST_PXE_EFI64/bootx64.efi
dhcp-option=tag:x86_BIOS, option6:bootfile-url, tftp://[fd80::$IP_ETH0]/$DST_PXE_BIOS/lpxelinux.0
dhcp-option=tag:x86_UEFI, option6:bootfile-url, tftp://[fd80::$IP_ETH0]/$DST_PXE_EFI32/bootia32.efi
dhcp-option=tag:x64_UEFI, option6:bootfile-url, tftp://[fd80::$IP_ETH0]/$DST_PXE_EFI64/bootx64.efi
EOF
        sudo systemctl restart dnsmasq.service;
    }
}


##########################################################################
handle_samba() {
    echo -e "\e[32mhandle_samba()\e[0m";

    ######################################################################
    grep -q mod_install_server /etc/samba/smb.conf 2> /dev/null || ( \
        echo -e "\e[36m    setup samba\e[0m";
        tar -ravf $BACKUP_FILE -C / etc/samba/smb.conf
        #sudo sed -i /etc/samba/smb.conf -n -e "1,/#======================= Share Definitions =======================/p";
        cat << EOF | sudo tee /etc/samba/smb.conf &>/dev/null
########################################
## mod_install_server
#======================= Global Settings =======================
[global]

## Browsing/Identification ###
   workgroup = WORKGROUP
dns proxy = yes
enhanced browsing = no

#### Networking ####
interfaces = $IP_ETH0_0 $INTERFACE_ETH0
bind interfaces only = yes

#### Debugging/Accounting ####
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d

####### Authentication #######
   server role = standalone server
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user

########## Domains ###########

############ Misc ############
   usershare allow guests = yes

#======================= Share Definitions =======================
[srv]
    path = $DST_ROOT
    comment = /srv folder of pxe-server
    guest ok = yes
    guest only = yes
    browseable = no
    read only = no
    create mask = 0644
    directory mask = 0755
    force create mode = 0644
    force directory mode = 0755
    force user = root
    force group = root
    hide dot files = no

[media]
    path = /media/
    comment = /media folder of pxe-server
    guest ok = yes
    guest only = yes
    browseable = no
    read only = no
    create mask = 0644
    directory mask = 0755
    force create mode = 0644
    force directory mode = 0755
    force user = root
    force group = root
    hide dot files = no
EOF
        sudo systemctl restart smbd.service;
    )
}


##########################################################################
handle_pxe_menu() {
    # $1 : menu short name
    # $2 : menu file name
    ######################################################################
    local FILE_MENU=$DST_TFTP_ETH0/$1/pxelinux.cfg/$2
    local FILE_BASE=http://$IP_ETH0
    ######################################################################
    ## INFO:
    ## The entry before -- means that it will be used by the live system / the installer
    ## The entry after -- means that it will be carried to and used by the installed system
    ## https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/kernel-parameters.txt
    ######################################################################
    echo -e "\e[32mhandle_pxe_menu(\e[0m$1\e[32m)\e[0m";
    echo -e "\e[36m    setup sys menu for pxe\e[0m";
    if ! [ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ]; then sudo mkdir -p $DST_TFTP_ETH0/$1/pxelinux.cfg; fi
    if [ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ]; then
        sudo sh -c "cat << EOF  > $FILE_MENU
########################################
# $FILE_MENU

# http://www.syslinux.org/wiki/index.php?title=Menu

DEFAULT vesamenu.c32
#TIMEOUT 600
#ONTIMEOUT localboot
PROMPT 0
NOESCAPE 1
ALLOWOPTIONS 1

menu color title * #FFFFFFFF *
menu title PXE Boot Menu (menu-bios)
menu rows 20
menu tabmsgrow 24
menu tabmsg [Enter]=boot, [Tab]=edit, [Esc]=return
menu cmdlinerow 24
menu timeoutrow 25
menu color help 1;37;40 #FFFFFFFF *
menu helpmsgrow 26

########################################
LABEL reboot
    MENU LABEL Reboot
    COM32 reboot.c32
########################################
LABEL poweroff
    MENU LABEL Power Off
    COM32 poweroff.c32


EOF";
    fi

. "$script_dir/p2-include-menu.sh"
}


######################################################################
handle_pxe() {
    echo -e "\e[32mhandle_pxe()\e[0m";

    ######################################################################
    [ -d "$DST_TFTP_ETH0/$DST_PXE_BIOS" ]            || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_BIOS;
    if [ -d "$SRC_TFTP_ETH0" ]; then
        echo -e "\e[36m    copy win-pe stuff\e[0m";
        if ! [ -f "$DST_TFTP_ETH0/$DST_PXE_BIOS/pxeboot.n12" ] && [ -f "$SRC_TFTP_ETH0/pxeboot.n12" ]; then sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/pxeboot.n12  $DST_TFTP_ETH0/$DST_PXE_BIOS/; fi
        if ! [ -f "$DST_TFTP_ETH0/bootmgr.exe" ] && [ -f "$SRC_TFTP_ETH0/bootmgr.exe" ]; then sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/bootmgr.exe  $DST_TFTP_ETH0/; fi
        if ! [ -d "$DST_TFTP_ETH0/Boot" ] && [ -d "$SRC_TFTP_ETH0/Boot" ]; then sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/Boot  $DST_TFTP_ETH0/; fi
    fi
    [ -h "$DST_TFTP_ETH0/sources" ]                  || sudo ln -s $DST_NFS_ETH0/$WIN_PE_X86/sources/  $DST_TFTP_ETH0/sources;
    #for SRC in `find /srv/tftp/Boot -depth`
    #do
    #    DST=`dirname "${SRC}"`/`basename "${SRC}" | tr '[A-Z]' '[a-z]'`
    #    if [ "${SRC}" != "${DST}" ]
    #    then
    #        [ ! -e "${DST}" ] && sudo mv -T "${SRC}" "${DST}" || echo "${SRC} was not renamed"
    #    fi
    #done


    ######################################################################
    echo -e "\e[36m    setup sys menu files for pxe bios\e[0m";
    [ -d "$DST_TFTP_ETH0/$DST_PXE_BIOS" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_BIOS;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/lpxelinux.0" ]  || sudo ln -s /usr/lib/PXELINUX/lpxelinux.0                $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/ldlinux.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/bios/ldlinux.c32   $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/bios/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/reboot.c32" ]   || sudo ln -s /usr/lib/syslinux/modules/bios/reboot.c32    $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/poweroff.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/poweroff.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/memdisk" ]      || sudo ln -s /usr/lib/syslinux/memdisk                    $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                               $DST_TFTP_ETH0/$DST_PXE_BIOS/nfs;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/iso" ]          || sudo ln -s $DST_ISO/                                    $DST_TFTP_ETH0/$DST_PXE_BIOS/iso;

    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/linux.c32" ]    || sudo ln -s /usr/lib/syslinux/modules/bios/linux.c32     $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -f "$DST_TFTP_ETH0/$DST_PXE_BIOS/wimboot" ] || ( \
    wget -O /tmp/wimboot.tar.gz https://git.ipxe.org/releases/wimboot/wimboot-latest.tar.gz; \
    tar -xf /tmp/wimboot.tar.gz --wildcards *wimboot -O | sudo tee $DST_TFTP_ETH0/$DST_PXE_BIOS/wimboot > /dev/null);

    handle_pxe_menu  $DST_PXE_BIOS  default;

    ######################################################################
    echo -e "\e[36m    setup sys menu files for pxe efi32\e[0m";
    [ -d "$DST_TFTP_ETH0/$DST_PXE_EFI32" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_EFI32;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/bootia32.efi" ] || sudo ln -s /usr/lib/SYSLINUX.EFI/efi32/syslinux.efi      $DST_TFTP_ETH0/$DST_PXE_EFI32/bootia32.efi;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/ldlinux.e32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi32/ldlinux.e32   $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi32/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/reboot.c32" ]   || sudo ln -s /usr/lib/syslinux/modules/efi32/reboot.c32    $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/poweroff.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/poweroff.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                                $DST_TFTP_ETH0/$DST_PXE_EFI32/nfs;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/iso" ]          || sudo ln -s $DST_ISO/                                     $DST_TFTP_ETH0/$DST_PXE_EFI32/iso;

    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/linux.c32" ]    || sudo ln -s /usr/lib/syslinux/modules/efi32/linux.c32     $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -f "$DST_TFTP_ETH0/$DST_PXE_EFI32/wimboot" ] || ( \
    wget -O /tmp/wimboot.tar.gz https://git.ipxe.org/releases/wimboot/wimboot-latest.tar.gz; \
    tar -xf /tmp/wimboot.tar.gz --wildcards *wimboot -O | sudo tee $DST_TFTP_ETH0/$DST_PXE_EFI32/wimboot > /dev/null);

    handle_pxe_menu  $DST_PXE_EFI32  default;

    ######################################################################
    echo -e "\e[36m    setup sys menu files for pxe efi64\e[0m";
    [ -d "$DST_TFTP_ETH0/$DST_PXE_EFI64" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_EFI64;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/bootx64.efi" ]  || sudo ln -s /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi      $DST_TFTP_ETH0/$DST_PXE_EFI64/bootx64.efi;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/ldlinux.e64" ]  || sudo ln -s /usr/lib/syslinux/modules/efi64/ldlinux.e64   $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi64/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/reboot.c32" ]   || sudo ln -s /usr/lib/syslinux/modules/efi64/reboot.c32    $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/poweroff.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/poweroff.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                                $DST_TFTP_ETH0/$DST_PXE_EFI64/nfs;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/iso" ]          || sudo ln -s $DST_ISO/                                     $DST_TFTP_ETH0/$DST_PXE_EFI64/iso;

    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/linux.c32" ]    || sudo ln -s /usr/lib/syslinux/modules/efi64/linux.c32     $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -f "$DST_TFTP_ETH0/$DST_PXE_EFI64/wimboot" ] || ( \
    wget -O /tmp/wimboot.tar.gz https://git.ipxe.org/releases/wimboot/wimboot-latest.tar.gz; \
    tar -xf /tmp/wimboot.tar.gz --wildcards *wimboot -O | sudo tee $DST_TFTP_ETH0/$DST_PXE_EFI64/wimboot > /dev/null);

    handle_pxe_menu  $DST_PXE_EFI64  default;
}


##########################################################################
compare_last_modification_time() {
    python3 - << EOF "$1" "$2"
import sys
import os
import urllib.request
import time

try:
    arg_file = sys.argv[1]
    stat_file = os.stat(arg_file)
    time_file = time.gmtime(stat_file.st_mtime)

    arg_url = sys.argv[2]
    conn_url = urllib.request.urlopen(arg_url)
    time_url = time.strptime(conn_url.headers['last-modified'], '%a, %d %b %Y %H:%M:%S %Z')

    if time_url <= time_file:
        exit_code = 0
    else:
        exit_code = 1

    print('file:{} <-> url:{}'.format(time.strftime("%Y-%m-%d %H:%M:%S", time_file), time.strftime("%Y-%m-%d %H:%M:%S", time_url)))
except:
    exit_code = 1

sys.exit(exit_code)
EOF
}


##########################################################################
handle_iso() {
    echo -e "\e[32mhandle_iso(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    # $2 : download url
    # $3 : optional/additional mount flags
    ######################################################################
    local NAME=$1
    local URL=$2
    local FILE_URL=$NAME.url
    local FILE_ISO=$NAME.iso
    local DST_ORIGINAL=/srv/tmp/original/$NAME
    ######################################################################

    if ! [ -d "$DST_ISO/" ]; then sudo mkdir -p $DST_ISO/; fi
    if ! [ -d "$DST_NFS_ETH0/" ]; then sudo mkdir -p $DST_NFS_ETH0/; fi

    sudo exportfs -u *:$DST_NFS_ETH0/$NAME 2> /dev/null;
    sudo umount -f $DST_NFS_ETH0/$NAME 2> /dev/null;

    if [ -z $URL ]; then
        if ! [ -s "$DST_ISO/$FILE_ISO" ] \
        && [ -s "$SRC_ISO/$FILE_ISO" ] \
        && [ -f "$SRC_ISO/$FILE_URL" ]; \
        then
            echo -e "\e[36m    copy iso from usb-stick\e[0m";
            sudo rm -f $DST_ISO/$FILE_URL;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_ISO  $DST_ISO;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_URL  $DST_ISO;
        fi
    else
        if [ -s "$SRC_ISO/$FILE_ISO" ] \
        && [ -f "$SRC_ISO/$FILE_URL" ] \
        && grep -q "$URL" $SRC_ISO/$FILE_URL 2> /dev/null \
        && ! grep -q "$URL" $DST_ISO/$FILE_URL 2> /dev/null; \
        then
            echo -e "\e[36m    copy iso from usb-stick\e[0m";
            sudo rm -f $DST_ISO/$FILE_URL;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_ISO  $DST_ISO;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_URL  $DST_ISO;
        fi

        if ! [ -s "$DST_ISO/$FILE_ISO" ] \
        || ! grep -q "$URL" $DST_ISO/$FILE_URL 2> /dev/null \
        || ([ "$3" == "timestamping" ] && ! compare_last_modification_time $DST_ISO/$FILE_ISO $URL); \
        then
            echo -e "\e[36m    download iso image\e[0m";
            sudo rm -f $DST_ISO/$FILE_URL;
            sudo rm -f $DST_ISO/$FILE_ISO;
            sudo wget -O $DST_ISO/$FILE_ISO  $URL;

            sudo sh -c "echo '$URL' > $DST_ISO/$FILE_URL";
            sudo touch -r $DST_ISO/$FILE_ISO  $DST_ISO/$FILE_URL;
        fi
    fi

    if ! [ -s $DST_ISO/$FILE_ISO ]; then
        sudo rm -f $DST_ISO/$FILE_ISO;
        sudo rm -f $DST_ISO/$FILE_URL;
    fi

    if [ -s "$DST_ISO/$FILE_ISO" ]; then
        if ! [ -d "$DST_NFS_ETH0/$NAME" ]; then
            echo -e "\e[36m    create nfs folder\e[0m";
            sudo mkdir -p $DST_NFS_ETH0/$NAME;
        fi

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/fstab; then
            echo -e "\e[36m    add iso image to fstab\e[0m";
            if [ "$3" == "timestamping" ]; then
                sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_NFS_ETH0/$NAME  auto  ro,nofail,auto,loop$4  0  10' >> /etc/fstab";
            else
                sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_NFS_ETH0/$NAME  auto  ro,nofail,auto,loop$3  0  10' >> /etc/fstab";
            fi
        fi

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/exports; then
            echo -e "\e[36m    add nfs folder to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_ETH0/$NAME  *(ro,async,no_subtree_check,root_squash,mp,fsid=$(uuid))' >> /etc/exports";
        fi

        sudo mount $DST_NFS_ETH0/$NAME;
        sudo exportfs *:$DST_NFS_ETH0/$NAME;
    else
        sudo sed /etc/fstab   -i -e "/$NAME/d"
        sudo sed /etc/exports -i -e "/$NAME/d"
    fi
}


##########################################################################
_unhandle_iso() {
    if [ "_$1_" == "__" ]; then return 0; fi

    echo -e "\e[32m_unhandle_iso(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    ######################################################################
    local NAME=$1
    local FILE_URL=$NAME.url
    local FILE_ISO=$NAME.iso
    ######################################################################

    sudo exportfs -u *:$DST_NFS_ETH0/$NAME 2> /dev/null;
    sudo umount -f $DST_NFS_ETH0/$NAME 2> /dev/null;

    sudo rm -f $DST_ISO/$FILE_URL;
    sudo rm -f $DST_ISO/$FILE_ISO;

    sudo rm -rf $DST_NFS_ETH0/$NAME;

    sudo sed /etc/fstab   -i -e "/$NAME/d"
    sudo sed /etc/exports -i -e "/$NAME/d"
}


##########################################################################
handle_kernel() {
    echo -e "\e[32mhandle_kernel(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    # $2 : download url
    # $3 : optional/additional mount flags
    ######################################################################
    local NAME=$1
    local URL=$2
    local FILE_URL=$NAME.url
    local FILE_KERNEL=$NAME.kernel
    local DST_ORIGINAL=/srv/tmp/original/$NAME
    ######################################################################

    if ! [ -d "$DST_NFS_ETH0/" ]; then sudo mkdir -p $DST_NFS_ETH0/; fi

    sudo exportfs -u *:$DST_NFS_ETH0/$NAME 2> /dev/null;

    if [ -z $URL ]; then
        if ! [ -s "$DST_ISO/$FILE_KERNEL" ] \
        && [ -s "$SRC_ISO/$FILE_KERNEL" ] \
        && [ -f "$SRC_ISO/$FILE_URL" ]; \
        then
            echo -e "\e[36m    copy kernel from usb-stick\e[0m";
            sudo rm -f $DST_ISO/$FILE_URL;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_KERNEL  $DST_ISO;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_URL     $DST_ISO;
        fi
    else
        if [ -s "$SRC_ISO/$FILE_KERNEL" ] \
        && [ -f "$SRC_ISO/$FILE_URL" ] \
        && grep -q "$URL" $SRC_ISO/$FILE_URL 2> /dev/null \
        && ! grep -q "$URL" $DST_ISO/$FILE_URL 2> /dev/null; \
        then
            echo -e "\e[36m    copy kernel from usb-stick\e[0m";
            sudo rm -f $DST_ISO/$FILE_URL;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_KERNEL  $DST_ISO;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_URL     $DST_ISO;
        fi

        if ! [ -s "$DST_ISO/$FILE_KERNEL" ] \
        || ! grep -q "$URL" $DST_ISO/$FILE_URL 2> /dev/null \
        || ([ "$3" == "timestamping" ] && ! compare_last_modification_time $DST_ISO/$FILE_KERNEL $URL); \
        then
            echo -e "\e[36m    download kernel image\e[0m";
            sudo rm -f $DST_ISO/$FILE_URL;
            sudo rm -f $DST_ISO/$FILE_KERNEL;
            sudo wget -O $DST_ISO/$FILE_KERNEL  $URL;

            sudo sh -c "echo '$URL' > $DST_ISO/$FILE_URL";
            sudo touch -r $DST_ISO/$FILE_KERNEL  $DST_ISO/$FILE_URL;
        fi
    fi

    if ! [ -s $DST_ISO/$FILE_KERNEL ]; then
        sudo rm -f $DST_ISO/$FILE_KERNEL;
        sudo rm -f $DST_ISO/$FILE_URL;
    fi

    if [ -s "$DST_ISO/$FILE_KERNEL" ]; then
        if ! [ -d "$DST_NFS_ETH0/$NAME" ]; then
            echo -e "\e[36m    create nfs folder\e[0m";
            sudo mkdir -p $DST_NFS_ETH0/$NAME;
        fi

        sudo cp $DST_ISO/$FILE_KERNEL  $DST_NFS_ETH0/$NAME/kernel

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/exports; then
            echo -e "\e[36m    add nfs folder to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_ETH0/$NAME  *(ro,async,no_subtree_check,root_squash,mp,fsid=$(uuid))' >> /etc/exports";
        fi

        sudo exportfs *:$DST_NFS_ETH0/$NAME;
    else
        sudo sed /etc/exports -i -e "/$NAME/d"
    fi
}


##########################################################################
_unhandle_kernel() {
    if [ "_$1_" == "__" ]; then return 0; fi

    echo -e "\e[32m_unhandle_kernel(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    ######################################################################
    local NAME=$1
    local FILE_URL=$NAME.url
    local FILE_KERNEL=$NAME.kernel
    ######################################################################

    sudo exportfs -u *:$DST_NFS_ETH0/$NAME 2> /dev/null;

    sudo rm -f $DST_ISO/$FILE_URL;
    sudo rm -f $DST_ISO/$FILE_KERNEL;

    sudo rm -rf $DST_NFS_ETH0/$NAME;

    sudo sed /etc/exports -i -e "/$NAME/d"
}


##########################################################################
handle_zip_img() {
    echo -e "\e[32mhandle_zip_img(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    # $2 : download url
    ######################################################################
    local NAME=$1
    local URL=$2
    local RAW_FILENAME=$(basename $URL .zip)
    local RAW_FILENAME_ZIP=$RAW_FILENAME.zip
    local NAME_BOOT=$NAME-boot
    local NAME_ROOT=$NAME-root
    local DST_NFS_BOOT=$DST_NFS_ETH0/$NAME_BOOT
    local DST_NFS_ROOT=$DST_NFS_ETH0/$NAME_ROOT
    local FILE_URL=$NAME.url
    local FILE_IMG=$NAME.img
    ######################################################################

    if ! [ -d "$DST_IMG/" ]; then sudo mkdir -p $DST_IMG/; fi
    if ! [ -d "$DST_NFS_ETH0/" ]; then sudo mkdir -p $DST_NFS_ETH0/; fi

    sudo exportfs -u *:$DST_NFS_BOOT 2> /dev/null;
    sudo umount -f $DST_NFS_BOOT 2> /dev/null;

    sudo exportfs -u *:$DST_NFS_ROOT 2> /dev/null;
    sudo umount -f $DST_NFS_ROOT 2> /dev/null;

    if [ -z $URL ]; then
        if ! [ -s "$DST_IMG/$FILE_IMG" ] \
        && [ -s "$SRC_IMG/$FILE_IMG" ] \
        && [ -f "$SRC_IMG/$FILE_URL" ]; \
        then
            echo -e "\e[36m    copy img from usb-stick\e[0m";
            sudo rm -f $FILE_IMG/$FILE_URL;
            sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_IMG  $DST_IMG;
            sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_URL  $DST_IMG;
        fi
    else
        if [ -s "$SRC_IMG/$FILE_IMG" ] \
        && [ -f "$SRC_IMG/$FILE_URL" ] \
        && grep -q "$URL" $SRC_IMG/$FILE_URL 2> /dev/null \
        && ! grep -q "$URL" $DST_IMG/$FILE_URL 2> /dev/null; \
        then
            echo -e "\e[36m    copy img from usb-stick\e[0m";
            sudo rm -f $FILE_IMG/$FILE_URL;
            sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_IMG  $DST_IMG;
            sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_URL  $DST_IMG;
        fi

        if ! [ -s "$DST_IMG/$FILE_IMG" ] \
        || ! grep -q "$URL" $DST_IMG/$FILE_URL 2> /dev/null \
        || ([ "$3" == "timestamping" ] && ! compare_last_modification_time $DST_IMG/$FILE_URL $URL); \
        then
            echo -e "\e[36m    download image\e[0m";
            sudo rm -f $DST_IMG/$FILE_IMG;
            sudo rm -f $DST_IMG/$FILE_URL;
            sudo wget -O $DST_IMG/$RAW_FILENAME_ZIP  $URL;

            sudo sh -c "echo '$URL' > $DST_IMG/$FILE_URL";
            sudo touch -r $DST_IMG/$RAW_FILENAME_ZIP  $DST_IMG/$FILE_URL;

            echo -e "\e[36m    extract image\e[0m";
            sudo unzip $DST_IMG/$RAW_FILENAME_ZIP  -d $DST_IMG > /tmp/output.tmp;
            sudo rm -f $DST_IMG/$RAW_FILENAME_ZIP;
            local RAW_FILENAME_IMG=$(grep 'inflating' /tmp/output.tmp | cut -d':' -f2 | xargs basename)
            sudo mv $DST_IMG/$RAW_FILENAME_IMG  $DST_IMG/$FILE_IMG;
            rm /tmp/output.tmp
        fi
    fi

    if ! [ -s $DST_IMG/$FILE_IMG ]; then
        sudo rm -f $DST_IMG/$FILE_IMG;
        sudo rm -f $DST_IMG/$FILE_URL;
    fi

    if [ -s "$DST_IMG/$FILE_IMG" ]; then
        local OFFSET_BOOT=$((512*$(sfdisk -d $DST_IMG/$FILE_IMG | grep $DST_IMG/$FILE_IMG\1 | awk '{print $4}' | sed 's/,//')))
        local SIZE_BOOT=$((512*$(sfdisk -d $DST_IMG/$FILE_IMG | grep $DST_IMG/$FILE_IMG\1 | awk '{print $6}' | sed 's/,//')))
        local OFFSET_ROOT=$((512*$(sfdisk -d $DST_IMG/$FILE_IMG | grep $DST_IMG/$FILE_IMG\2 | awk '{print $4}' | sed 's/,//')))
        local SIZE_ROOT=$((512*$(sfdisk -d $DST_IMG/$FILE_IMG | grep $DST_IMG/$FILE_IMG\2 | awk '{print $6}' | sed 's/,//')))
        #sfdisk -d $DST_IMG/$FILE_IMG

        sudo sed /etc/fstab   -i -e "/$NAME_BOOT/d"
        sudo sed /etc/fstab   -i -e "/$NAME_ROOT/d"

        ## boot
        if ! [ -d "$DST_NFS_BOOT" ]; then
            echo -e "\e[36m    create image-boot folder\e[0m";
            sudo mkdir -p $DST_NFS_BOOT;
        fi

        if ! grep -q "$DST_NFS_BOOT" /etc/fstab; then
            echo -e "\e[36m    add image-boot to fstab\e[0m";
            sudo sh -c "echo '$DST_IMG/$FILE_IMG  $DST_NFS_BOOT  auto  ro,nofail,auto,loop,offset=$OFFSET_BOOT,sizelimit=$SIZE_BOOT  0  11' >> /etc/fstab";
        fi

        if ! grep -q "$DST_NFS_BOOT" /etc/exports; then
            echo -e "\e[36m    add image-boot folder to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_BOOT  *(ro,async,no_subtree_check,root_squash,mp,fsid=$(uuid))' >> /etc/exports";
        fi

        ## root
        if ! [ -d "$DST_NFS_ROOT" ]; then
            echo -e "\e[36m    create image-root folder\e[0m";
            sudo mkdir -p $DST_NFS_ROOT;
        fi

        if ! grep -q "$DST_NFS_ROOT" /etc/fstab; then
            echo -e "\e[36m    add image-root to fstab\e[0m";
            sudo sh -c "echo '$DST_IMG/$FILE_IMG  $DST_NFS_ROOT  auto  ro,nofail,auto,loop,offset=$OFFSET_ROOT,sizelimit=$SIZE_ROOT  0  11' >> /etc/fstab";
        fi

        if ! grep -q "$DST_NFS_ROOT" /etc/exports; then
            echo -e "\e[36m    add image-root folder to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_ROOT  *(ro,async,no_subtree_check,root_squash,mp,fsid=$(uuid))' >> /etc/exports";
        fi

        sudo mount $DST_NFS_BOOT;
        sudo exportfs *:$DST_NFS_BOOT;

        sudo mount $DST_NFS_ROOT;
        sudo exportfs *:$DST_NFS_ROOT;
    else
        ## boot
        sudo sed /etc/fstab   -i -e "/$NAME_BOOT/d"
        sudo sed /etc/exports -i -e "/$NAME_BOOT/d"
        ## root
        sudo sed /etc/fstab   -i -e "/$NAME_ROOT/d"
        sudo sed /etc/exports -i -e "/$NAME_ROOT/d"
    fi
}


##########################################################################
_unhandle_zip_img() {
    echo -e "\e[32m_unhandle_zip_img(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    # $2 : download url
    ######################################################################
    local NAME=$1
    local URL=$2
    local NAME_BOOT=$NAME-boot
    local NAME_ROOT=$NAME-root
    local DST_NFS_BOOT=$DST_NFS_ETH0/$NAME_BOOT
    local DST_NFS_ROOT=$DST_NFS_ETH0/$NAME_ROOT
    local FILE_URL=$NAME.url
    local FILE_IMG=$NAME.img
    ######################################################################

    ## boot
    sudo exportfs -u *:$DST_NFS_BOOT 2> /dev/null;
    sudo umount -f $DST_NFS_BOOT 2> /dev/null;
    sudo rm -rf $DST_NFS_BOOT;
    sudo sed /etc/fstab   -i -e "/$NAME_BOOT/d"
    sudo sed /etc/exports -i -e "/$NAME_BOOT/d"

    ## root
    sudo exportfs -u *:$DST_NFS_ROOT 2> /dev/null;
    sudo umount -f $DST_NFS_ROOT 2> /dev/null;
    sudo rm -rf $DST_NFS_ROOT;
    sudo sed /etc/fstab   -i -e "/$NAME_ROOT/d"
    sudo sed /etc/exports -i -e "/$NAME_ROOT/d"

    ## img
    sudo rm -f $DST_IMG/$FILE_IMG;
    sudo rm -f $DST_IMG/$FILE_URL;
}


######################################################################
handle_rpi_pxe() {
    # $1 : short name
    # $2 : flags (redo,bootcode,cmdline,config,ssh,root,fstab,wpa,history)
    ##############################################################
    local NAME=$1
    local FLAGS=$2
    local NAME_BOOT=$NAME-boot
    local NAME_ROOT=$NAME-root
    local SRC_BOOT=$DST_NFS_ETH0/$NAME_BOOT
    local SRC_ROOT=$DST_NFS_ETH0/$NAME_ROOT
    local DST_BOOT=$DST_NFS_ETH0/$RPI_SN0_BOOT
    local DST_ROOT=$DST_NFS_ETH0/$RPI_SN0_ROOT
    local FILE_URL=$NAME.url
    ##############################################################
    echo -e "\e[32mhandle_rpi_pxe(\e[0m$NAME\e[32m)\e[0m";
    if [ "$RPI_SN0" == "--------" ]; then
        echo -e "\e[36m    skipped: no serial number setted at RPI_SN0.\e[0m";
        return 1;
    fi
    sudo exportfs -u *:$DST_BOOT 2> /dev/null;
    sudo exportfs -u *:$DST_ROOT 2> /dev/null;

    ######################################################################
    if ! [ -d "$DST_BOOT" ]; then sudo mkdir -p $DST_BOOT; fi
    if ! [ -d "$DST_ROOT" ]; then sudo mkdir -p $DST_ROOT; fi

    ######################################################################
    if ! [ -h "$DST_TFTP_ETH0/$RPI_SN0" ]; then sudo ln -s $DST_BOOT/  $DST_TFTP_ETH0/$RPI_SN0; fi

    ######################################################################
    if (echo $FLAGS | grep -q redo) \
    || ! grep -q $(cat $DST_IMG/$FILE_URL)  $DST_BOOT/$FILE_URL 2> /dev/null; then
        echo -e "\e[36m    delete old boot files\e[0m";
        sudo rm -rf $DST_BOOT/*;
        echo -e "\e[36m    delete old root files\e[0m";
        sudo rm -rf $DST_ROOT/*;

        ##################################################################
        if ! [ -f "$DST_BOOT/bootcode.bin" ]; then
            echo -e "\e[36m    copy boot files\e[0m";
            sudo rsync -xa --info=progress2 $SRC_BOOT/*  $DST_BOOT/
        fi

        ##################################################################
        if (echo $FLAGS | grep -q cmdline); then
            echo -e "\e[36m    add cmdline file\e[0m";
            sudo sh -c "echo 'dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 plymouth.ignore-serial-consoles root=/dev/nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$RPI_SN0_ROOT,vers=3 rw ip=dhcp rootwait net.ifnames=0 elevator=deadline' > $DST_BOOT/cmdline.txt";
        fi

        ##################################################################
        if (echo $FLAGS | grep -q config); then
            echo -e "\e[36m    add config file\e[0m";
            cat << EOF | sudo tee $DST_BOOT/config.txt
# Enable audio (loads snd_bcm2835)
dtparam=audio=on

[pi4]
# Enable DRM VC4 V3D driver on top of the dispmanx display stack
dtoverlay=vc4-fkms-v3d
max_framebuffers=2

[all]
#dtoverlay=vc4-fkms-v3d

disable_overscan=1
max_usb_current=1

hdmi_force_hotplug=1

#hdmi_ignore_cec=1
#hdmi_ignore_cec_init=1
cec_osd_name=NetBoot

disable_splash=1
EOF
        fi

        ##################################################################
        if (echo $FLAGS | grep -q ssh); then
            echo -e "\e[36m    add ssh file\e[0m";
            sudo touch $DST_BOOT/ssh;
        fi

        ##################################################################
        if (echo $FLAGS | grep -q root); then
            if ! [ -d "$DST_ROOT/etc" ]; then
                echo -e "\e[36m    copy root files\e[0m";
                sudo rsync -xa --info=progress2 $SRC_ROOT/*  $DST_ROOT/
            fi

            ##############################################################
            if (echo $FLAGS | grep -q fstab); then
                echo -e "\e[36m    add fstab file\e[0m";
                cat << EOF | sudo tee $DST_ROOT/etc/fstab &>/dev/null
########################################
proc  /proc  proc  defaults  0  0
$IP_ETH0:$DST_NFS_ETH0/$RPI_SN0_BOOT  /      nfs   defaults,noatime  0  1
$IP_ETH0:$DST_NFS_ETH0/$RPI_SN0_ROOT  /boot  nfs   defaults,noatime  0  2
EOF
            fi

            ##############################################################
            if (echo $FLAGS | grep -q wpa); then
                echo -e "\e[36m    add wpa_supplicant template file\e[0m";
                cat << EOF | sudo tee $DST_ROOT/etc/wpa_supplicant/wpa_supplicant.conf &>/dev/null
########################################
country=$COUNTRY_WLAN0
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    # wpa_passphrase <SSID> <PASSWORD>
    #ssid=<ssid>
    #psk=<pks>

    # sudo iwlist wlan0 scan  [essid <SSID>]
    #bssid=<mac>

    scan_ssid=1
    key_mgmt=WPA-PSK
}
EOF
                if [ -f "$SRC_BACKUP/wpa_supplicant.conf" ]; then
                    echo -e "\e[36m    add wpa_supplicant file from backup\e[0m";
                    sudo rsync -xa --info=progress2 $SRC_BACKUP/wpa_supplicant.conf  $DST_ROOT/etc/wpa_supplicant/
                fi
            fi

            ##############################################################
            if (echo $FLAGS | grep -q history); then
                echo -e "\e[36m    add .bash_history file\e[0m";
                cat << EOF | sudo tee $DST_ROOT/home/pi/.bash_history &>/dev/null
sudo poweroff
sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y --purge && sudo apt autoclean -y && sync && echo Done.
sudo nano /etc/resolv.conf
ip route
sudo ip route del default dev eth0
sudo reboot
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
wpa_passphrase <SSID> <PASSWORD>
sudo iwlist wlan0 scan  [essid <SSID>]
sudo raspi-config
EOF
                sudo chown 1000:1000 $DST_ROOT/home/pi/.bash_history;
            fi
        fi

        ##################################################################
        sudo cp $DST_IMG/$FILE_URL $DST_BOOT/$FILE_URL;
    fi

    ######################################################################
    if ! grep -q "$DST_BOOT" /etc/exports; then
        echo -e "\e[36m    add $DST_BOOT to exports\e[0m";
        sudo sh -c "echo '$DST_BOOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
    fi
    sudo exportfs *:$DST_BOOT;

    ######################################################################
    if (echo $FLAGS | grep -q root); then
        if ! grep -q "$DST_ROOT" /etc/exports; then
            echo -e "\e[36m    add $DST_ROOT to exports\e[0m";
            sudo sh -c "echo '$DST_ROOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
        fi
        sudo exportfs *:$DST_ROOT;
    else
        sudo sed /etc/exports -i -e "/$NAME_ROOT/d"
    fi

    ######################################################################
    if (echo $FLAGS | grep -q bootcode); then
        if [ -f "$DST_BOOT/bootcode.bin" ]; then
            echo -e "\e[36m    copy bootcode.bin for RPi3 NETWORK BOOTING\e[0m";
            sudo cp $DST_BOOT/bootcode.bin $DST_TFTP_ETH0/bootcode.bin;
        fi
    fi

    ######################################################################
    if ! [ -f "$DST_TFTP_ETH0/bootcode.bin" ]; then
        echo -e "\e[36m    download bootcode.bin for RPi3 NETWORK BOOTING\e[0m";
        sudo wget -O $DST_TFTP_ETH0/bootcode.bin  https://github.com/raspberrypi/firmware/raw/stable/boot/bootcode.bin;
    fi
}


######################################################################
handle_optional() {
    echo -e "\e[32mhandle_optional()\e[0m";

    ######################################################################
    ## network nat
    grep -q mod_install_server /etc/sysctl.conf 2> /dev/null || {
        echo -e "\e[36m    setup sysctrl for nat\e[0m";
        tar -ravf $BACKUP_FILE -C / etc/sysctl.conf
        cat << EOF | sudo tee -a /etc/sysctl.conf &>/dev/null
########################################
## mod_install_server
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.$INTERFACE_ETH0.accept_ra=2
net.ipv6.conf.$INTERFACE_ETH1.accept_ra=2
net.ipv6.conf.$INTERFACE_WLAN0.accept_ra=2
EOF
        sudo sysctl -p &>/dev/null
        sudo sysctl --system &>/dev/null
    }


    ######################################################################
    ## network nat
    sudo iptables -t nat --list | grep -q MASQUERADE 2> /dev/null || {
        echo -e "\e[36m    setup iptables for nat\e[0m";
        sudo iptables -t nat -A POSTROUTING -o $INTERFACE_ETH0 -j MASQUERADE -m comment --comment "NAT: masquerade traffic going out over $INTERFACE_ETH0"
        sudo dpkg-reconfigure --unseen-only iptables-persistent
    }
}


handle_chrony() {
    ######################################################################
    ## chrony
    grep -q mod_install_server /etc/chrony/chrony.conf 2> /dev/null || {
        echo -e "\e[36m    setup chrony\e[0m";
        tar -ravf $BACKUP_FILE -C / etc/chrony/chrony.conf
        cat << EOF | sudo tee /etc/chrony/chrony.conf &>/dev/null
########################################
## mod_install_server
allow

server  ptbtime1.ptb.de  iburst
server  ptbtime2.ptb.de  iburst
server  ptbtime3.ptb.de  iburst
server  ntp1.oma.be  iburst
server  ntp2.oma.be  iburst

pool  $CUSTOM_LANG.pool.ntp.org  iburst

keyfile /etc/chrony/chrony.keys
driftfile /var/lib/chrony/chrony.drift
logdir /var/log/chrony
maxupdateskew 100.0
hwclockfile /etc/adjtime
rtcsync
makestep 1 5
EOF
        sudo systemctl restart chronyd.service;
    }
}


######################################################################
sudo mkdir -p $DST_ISO;
sudo mkdir -p $DST_IMG;
sudo mkdir -p $DST_TFTP_ETH0;
sudo mkdir -p $DST_NFS_ETH0;

##########################################################################
if [ -d "/var/www/html" ]; then
    [ -d "/var/www/html/srv" ] || sudo mkdir -p /var/www/html/srv
    [ -h "/var/www/html/srv$ISO" ]      || sudo ln -s $DST_ISO      /var/www/html/srv$ISO;
    [ -h "/var/www/html/srv$IMG" ]      || sudo ln -s $DST_IMG      /var/www/html/srv$IMG;
    [ -h "/var/www/html/srv$NFS_ETH0" ] || sudo ln -s $DST_NFS_ETH0 /var/www/html/srv$NFS_ETH0;
fi


######################################################################
handle_dhcpcd;
handle_dnsmasq;
handle_samba;
#handle_optional;
handle_chrony;


##########################################################################
##########################################################################
## comment out those entries,
##  you don't want to download, mount, export, install for PXE boot
## or
## "_unhandle_iso  ...",
##  if you want to delete the entire iso and its nfs export to free disk space
##########################################################################
##########################################################################
. "$script_dir/p2-include-handle.sh"


##########################################################################
handle_pxe;


##########################################################################
if [ -d "$SRC_ISO" ] && ! [ "$SRC_ISO" == "$DST_ISO" ]; then
    echo -e "\e[32mbackup new iso images to usb-stick\e[0m";
    sudo rsync -xa --info=progress2 $DST_ISO/*.iso $DST_ISO/*.url  $SRC_ISO/  2>/dev/null
fi
######################################################################
if [ -d "$SRC_IMG" ] && ! [ "$SRC_IMG" == "$DST_IMG" ]; then
    echo -e "\e[32mbackup new images to usb-stick\e[0m";
    sudo rsync -xa --info=progress2 $DST_IMG/*.img $DST_IMG/*.url  $SRC_IMG/  2>/dev/null
fi
##########################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
