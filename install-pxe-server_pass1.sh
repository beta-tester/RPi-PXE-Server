#!/bin/bash
######################################################################
echo -e "\e[32msetup variables\e[0m";
SRC_MOUNT=/media/server


######################################################################
grep Server /etc/fstab > /dev/null || ( \
echo -e "\e[32madd usb-stick to fstab\e[0m";
[ -d "%SRC_MOUNT/" ] || sudo mkdir -p $SRC_MOUNT;
sudo sh -c "echo '
## inserted by install-server.sh
LABEL=PXE-Server  $SRC_MOUNT  auto  defaults,noatime,auto,x-systemd.automount  0  0
' >> /etc/fstab"
sudo mount -a;
)


######################################################################
grep -q max_loop /boot/cmdline.txt 2> /dev/null || {
	echo -e "\e[32msetup cmdline.txt for more loop devices\e[0m";
	sudo sed -i '1 s/$/ max_loop=64/' /boot/cmdline.txt;
}


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
echo -e "\e[32menable port mapping and necessary services\e[0m";
sudo systemctl enable rpcbind.service;
sudo systemctl restart rpcbind.service;
sudo systemctl enable nfs-kernel-server.service;
sudo systemctl restart nfs-kernel-server.service;


######################################################################
echo -e "\e[32minstall dnsmasq for pxe\e[0m";
sudo apt-get -y install dnsmasq
sudo systemctl enable dnsmasq.service;
sudo systemctl restart dnsmasq.service;


######################################################################
echo -e "\e[32minstall samba\e[0m";
sudo apt-get -y install samba;


######################################################################
echo -e "\e[32minstall rsync\e[0m";
sudo apt-get -y install rsync;


######################################################################
echo -e "\e[32minstall syslinux-common for pxe\e[0m";
sudo apt-get -y install pxelinux syslinux-common


######################################################################
# fix for systemd dependency cycle
echo -e "\e[32mworkaround for systemd dependency cycle\e[0m";
grep -q nfs-kernel-server /etc/rc.local || sudo sed /etc/rc.local -i -e "s/^exit 0$/sudo systemctl restart nfs-kernel-server.service \&\n\nexit 0\n/";


######################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
