#!/bin/bash

######################################################################
#
# v2019-07-15
#
# known issues:
#

#bridge#


######################################################################
echo -e "\e[32msetup variables\e[0m";
SRC_MOUNT=/media/server


######################################################################
## optional
grep mod_install_server /etc/fstab > /dev/null || ( \
echo -e "\e[32madd usb-stick to fstab\e[0m";
[ -d "$SRC_MOUNT/" ] || sudo mkdir -p $SRC_MOUNT;
sudo sh -c "echo '
## mod_install_server
LABEL=PXE-Server  $SRC_MOUNT  auto  noatime,nofail,auto,x-systemd.automount,x-systemd.device-timeout=5,x-systemd.mount-timeout=5  0  0
' >> /etc/fstab"
sudo mount -a;
)


######################################################################
grep -q max_loop /boot/cmdline.txt 2> /dev/null || {
	echo -e "\e[32msetup cmdline.txt for more loop devices\e[0m";
	sudo sed -i '1 s/$/ max_loop=64/' /boot/cmdline.txt;
}


######################################################################
grep -q net.ifnames /boot/cmdline.txt 2> /dev/null || {
	echo -e "\e[32msetup cmdline.txt for old style network interface names\e[0m";
	sudo sed -i '1 s/$/ net.ifnames=0/' /boot/cmdline.txt;
}


######################################################################
sudo sync \
&& echo -e "\e[32mupdate...\e[0m" && sudo apt update -y \
&& echo -e "\e[32mupgrade...\e[0m" && sudo apt full-upgrade -y \
&& echo -e "\e[32mautoremove...\e[0m" && sudo apt autoremove -y --purge \
&& echo -e "\e[32mautoclean...\e[0m" && sudo apt autoclean \
&& sudo sync \
&& echo -e "\e[32mDone.\e[0m" \
;


######################################################################
echo -e "\e[32minstall nfs-kernel-server for pxe\e[0m";
sudo apt install -y nfs-kernel-server;
sudo systemctl enable nfs-kernel-server.service;
sudo systemctl restart nfs-kernel-server.service;

######################################################################
echo -e "\e[32menable port mapping\e[0m";
sudo systemctl enable rpcbind.service;
sudo systemctl restart rpcbind.service;


######################################################################
echo -e "\e[32minstall dnsmasq for pxe\e[0m";
sudo apt install -y dnsmasq
sudo systemctl enable dnsmasq.service;
sudo systemctl restart dnsmasq.service;


######################################################################
echo -e "\e[32minstall samba\e[0m";
sudo apt install -y samba;


######################################################################
echo -e "\e[32minstall rsync\e[0m";
sudo apt install -y rsync;


######################################################################
echo -e "\e[32minstall uuid\e[0m";
sudo apt install -y uuid;


#####################################################################
echo -e "\e[32minstall lighttpd\e[0m";
sudo apt install -y lighttpd;
sudo sh -c "cat << EOF  >> /etc/lighttpd/lighttpd.conf
########################################
## mod_install_server
dir-listing.activate = \"enable\" 
dir-listing.external-css = \"\"
dir-listing.external-js = \"\"
dir-listing.set-footer = \"&nbsp;<br />\"
dir-listing.exclude = ( \"[.]*\.url\" )
EOF";
sudo rm /var/www/html/index.lighttpd.html


######################################################################
echo -e "\e[32mdisable ntp\e[0m";
sudo systemctl stop ntp.service 1>/dev/null 2>/dev/null;
sudo systemctl disable ntp.service 1>/dev/null 2>/dev/null;

echo -e "\e[32minstall chrony as ntp client and ntp server\e[0m";
sudo apt install -y chrony;
sudo systemctl enable chronyd.service;
sudo systemctl restart chronyd.service;


######################################################################
echo -e "\e[32minstall syslinux-common for pxe\e[0m";
sudo apt install -y pxelinux syslinux-common syslinux-efi;


######################################################################
#bridge#echo -e "\e[32minstall network bridge\e[0m";
#bridge#sudo apt install -y bridge-utils hostapd dnsmasq iptables iptables-persistent


######################################################################
## optional
#bridge#echo -e "\e[32minstall wireshark\e[0m";
#bridge#sudo apt install -y wireshark
#bridge#sudo usermod -a -G wireshark $USER


######################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
