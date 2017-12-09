#!/bin/bash

######################################################################
#
# v2017-12-09
#
# known issues:
#

#bridge#


######################################################################
# disable screensaver on console
echo -e "\e[36m    disable term screensaver temporary\e[0m";
setterm -blank 0 -powerdown 0 2> /dev/null;
xset s off 2> /dev/null;
echo -e "\e[36m    done.\e[0m";
echo -e "\e[36m    disable X screensaver temporary\e[0m";
xset -dpms 2> /dev/null;
echo -e "\e[36m    done.\e[0m";


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
&& echo -e "\e[32mupdate...\e[0m" && sudo apt update \
&& echo -e "\e[32mupgrade...\e[0m" && sudo apt upgrade -y \
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
echo -e "\e[32minstall syslinux-common for pxe\e[0m";
sudo apt install -y pxelinux syslinux-common;


######################################################################
echo -e "\e[32minstall apt-cacher-ng\e[0m";
sudo apt install -y apt-cacher-ng;


######################################################################
echo -e "\e[32minstall bindfs\e[0m";
sudo apt install -y fuse bindfs;


######################################################################
#bridge#echo -e "\e[32minstall network bridge\e[0m";
#bridge#sudo apt install -y bridge-utils hostapd dnsmasq iptables iptables-persistent


######################################################################
echo -e "\e[32minstall network NAT\e[0m";
sudo apt install -y iptables iptables-persistent


######################################################################
$(dpkg --get-selections | grep -q -E "^(ntp|ntpd)[[:blank:]]*install$") || {
sudo apt install -y chrony;
sudo systemctl enable chronyd.service;
sudo systemctl restart chronyd.service;
}

######################################################################
######################################################################


######################################################################
## optional
echo -e "\e[32minstall wireshark\e[0m";
sudo apt install -y wireshark
sudo usermod -a -G wireshark $USER

#sudo apt purge -y --auto-remove avahi-daemon
sudo systemctl stop avahi-daemon.service
sudo systemctl disable avahi-daemon.service


######################################################################
## optional
grep -q mod_install_server /etc/rc.local 2> /dev/null || {
echo -e "\e[32m... disable screensaver\e[0m";
sudo sed /etc/rc.local -i -e "s/^exit 0$/########################################\n## mod_install_server\nsetterm -blank 0 -powerdown 0;\n\nexit 0/"
sudo sh -c "echo '########################################
## mod_install_server
setterm -blank 0 -powerdown 0;
xset s off;
xset -dpms;
' >> /etc/X11/Xsession.d/40x11-common_xsessionrc";
}


######################################################################
## optional
grep -q logo.nologo /boot/cmdline.txt 2> /dev/null || {
echo -e "\e[32msetup cmdline.txt for no logo\e[0m";
sudo sed -i '1 s/$/ logo.nologo/' /boot/cmdline.txt;
}


######################################################################
## optional
echo -e "\e[32mchange hostname\e[0m";
sudo sh -c "echo pxe-server > /etc/hostname"
sudo sed -i "s/127.0.1.1.*$(hostname)/127.0.1.1\tpxe-server/g" /etc/hosts


######################################################################
## optional
grep -q mod_install_server /boot/config.txt 2> /dev/null || {
echo -e "\e[32msetup /boot/config.txt\e[0m";
sudo sed /boot/config.txt -i -e 's/^max_usb_current=/\#max_usb_current=/g'
sudo sed /boot/config.txt -i -e 's/^force_turbo=/\#force_turbo=/g'
sudo sed /boot/config.txt -i -e 's/^disable_overscan=/\#disable_overscan=/g'
sudo sed /boot/config.txt -i -e 's/^hdmi_force_hotplug=/\#hdmi_force_hotplug=/g'
sudo sed /boot/config.txt -i -e 's/^config_hdmi_boost=/\#config_hdmi_boost=/g'
sudo sed /boot/config.txt -i -e 's/^hdmi_drive=/\#hdmi_drive=/g'
sudo sed /boot/config.txt -i -e 's/^cec_osd_name=/\#cec_osd_name=/g'
sudo sh -c "echo '########################################
## mod_install_server
[pi2]
total_mem=1024

[pi3]
total_mem=1024

[all]
max_usb_current=1
force_turbo=1

disable_overscan=1
config_hdmi_boost=4
hdmi_force_hotplug=1
hdmi_drive=2
hdmi_ignore_cec_init=1
cec_osd_name=PXE-Server
' >> /boot/config.txt"
}


######################################################################
## optional
grep -q mod_install_server /etc/rc.local 2> /dev/null || {
echo -e "\e[32mdisable screensaver\e[0m";
sudo sed /etc/rc.local -i -e 's/^exit 0$/\########################################\n## mod_install_server\nsetterm -blank 0 -powerdown 0;\n\nexit 0/'
sudo sh -c "echo '########################################
## mod_install_server
setterm -blank 0 -powerdown 0;
xset s off;
xset -dpms;
' >> /etc/X11/Xsession.d/40x11-common_xsessionrc";
}


######################################################################
## optional
[ -f /etc/ssh/mod_install_server ] || {
echo -e "\e[32mcopy predefined ssh keys\e[0m";
sudo touch /etc/ssh/mod_install_server
sudo rsync -xa --info=progress2 $SRC_MOUNT/backup/ssh/* /etc/ssh/
sudo chmod 0600 /etc/ssh/*key
sudo ssh-keygen -A
}


######################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
