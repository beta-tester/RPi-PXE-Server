#!/bin/bash
# bankix,    http://www.heise.de/ct/projekte/Sicheres-Online-Banking-mit-Bankix-284099.html
# debian,    http://cdimage.debian.org/debian-cd/
# deft,      http://www.deftlinux.net/
# gnuradio,  http://gnuradio.org/redmine/projects/gnuradio/wiki/GNURadioLiveDVD/
# kali,      http://www.kali.org/kali-linux-releases/
# pentoo,    http://www.pentoo.ch/download/
# sysrescue, http://sourceforge.net/projects/systemrescuecd/ (http://www.sysresccd.org/Download/)
# ubuntu,    http://releases.ubuntu.com/
#            https://help.ubuntu.com/community/Installation/MinimalCD
# nonpae,    ftp://ftp.heise.de/pub/ct/projekte/ubuntu-nonpae/ubuntu-12.04.4-nonpae.iso
# winpe,     https://msdn.microsoft.com/en-us/windows/hardware/dn913721.aspx
#
# v2016-03-17


######################################################################
echo -e "\e[32msetup variables\e[0m";
NFS=/nfs
TFTP=/tftp
ISO=/iso
SRC_MOUNT=/media/server
SRC_ROOT=$SRC_MOUNT$TFTP
SRC_ISO=$SRC_ROOT$ISO
SRC_NFS=$SRC_ROOT$NFS
DST_ROOT=/srv$TFTP
DST_ISO=$DST_ROOT$ISO
DST_NFS=$DST_ROOT$NFS
IP_LOCAL=$(echo $(hostname -I) | sed 's/ //g')
IP_LOCAL_=$(echo $IP_LOCAL | grep -E -o "([0-9]{1,3}[\.]){3}")
IP_LOCAL_0=$(echo $(echo $IP_LOCAL_)0)
IP_LOCAL_START=$(echo $(echo $IP_LOCAL_)200)
IP_LOCAL_END=$(echo $(echo $IP_LOCAL_)229)
IP_LOCAL_255=$(echo $(echo $IP_LOCAL_)255)
IP_ROUTER=$(grep "nameserver" /etc/resolv.conf | sed -r "s/nameserver([ ]{1,})//g")
IP_SUB=255.255.255.0


######################################################################
grep Server /etc/fstab > /dev/null || ( \
echo -e "\e[32madd usb-stick to fstab\e[0m";
[ -d "%SRC_MOUNT/" ] || sudo mkdir -p $SRC_MOUNT;
sudo sh -c "echo '
## inserted by install-server.sh
LABEL=PXE-Server  /media/server/  auto  defaults,noatime  0  0
' >> /etc/fstab"
sudo mount -a;
##sudo ln -s $SRC_ROOT/ $DST_ROOT;
sudo mkdir -p $DST_ROOT;
sudo mkdir -p $DST_ISO;
#sudo cp -p $SRC_ROOT/iso/*.iso $DST_ISO && sync
)


######################################################################
sudo sync \
&& echo -e "\e[32mupdate...\e[0m" && sudo apt-get -y update \
&& echo -e "\e[32mupgrade...\e[0m" && sudo apt-get -y upgrade \
&& echo -e "\e[32mautoremove...\e[0m" && sudo apt-get -y --purge autoremove \
&& echo -e "\e[32mautoclean...\e[0m" && sudo apt-get autoclean \
&& echo -e "\e[32mDone.\e[0m" \
&& sudo sync


######################################################################
echo -e "\e[32minstall nfs-kernel-server for pxe\e[0m";
sudo apt-get -y install nfs-kernel-server;


######################################################################
echo -e "\e[32minstall syslinux-common for pxe\e[0m";
sudo apt-get -y install pxelinux syslinux-common


######################################################################
echo -e "\e[32minstall dnsmasq for pxe\e[0m";
sudo apt-get -y install dnsmasq


######################################################################
echo -e "\e[32minstall samba\e[0m";
sudo apt-get -y install samba;


######################################################################
# fix for systemd dependency cycle
grep -q nfs-kernel-server /etc/rc.local || sudo sed /etc/rc.local -i -e "s/^exit 0$/sudo service nfs-kernel-server restart &\n\nexit 0/";


######################################################################
echo -e "\e[32mDone.\e[0m";
echo -e "\e[32mPlease reboot\e[0m";
