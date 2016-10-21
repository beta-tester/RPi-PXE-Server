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
# fix for systemd dependency cycle
echo -e "\e[32mworkaround for systemd dependency cycle\e[0m";
grep -q nfs-kernel-server /etc/rc.local || sudo sed /etc/rc.local -i -e "s/^exit 0$/sudo service nfs-kernel-server restart &\n\nexit 0/";


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
echo -e "\e[32mDone.\e[0m";
echo -e "\e[32mPlease reboot\e[0m";
