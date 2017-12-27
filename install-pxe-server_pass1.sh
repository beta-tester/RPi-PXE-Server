#!/bin/bash

######################################################################
#
# v2017-12-27
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
grep -q quiet /boot/cmdline.txt 2> /dev/null && {
    echo -e "\e[32msetup cmdline.txt for more boot output\e[0m";
    sudo sed -i '1 s/ quiet//' /boot/cmdline.txt;
}

######################################################################
grep -q splash /boot/cmdline.txt 2> /dev/null && {
    echo -e "\e[32msetup cmdline.txt for no splash screen\e[0m";
    sudo sed -i '1 s/ splash//' /boot/cmdline.txt;
}


######################################################################
echo -e "\e[32msync...\e[0m" && sudo sync \
&& echo -e "\e[32mupdate...\e[0m" && sudo apt update \
&& echo -e "\e[32mupgrade...\e[0m" && sudo apt upgrade -y \
&& echo -e "\e[32mautoremove...\e[0m" && sudo apt autoremove -y --purge \
&& echo -e "\e[32mautoclean...\e[0m" && sudo apt autoclean \
&& echo -e "\e[32msync...\e[0m" && sudo sync \
&& echo -e "\e[32mDone.\e[0m" \
;


######################################################################
echo -e "\e[32minstall debconf-utils\e[0m";
sudo apt install -y debconf-utils;


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
echo -e "\e[32minstall wlan access point\e[0m";
sudo apt install -y hostapd


######################################################################
#bridge#echo -e "\e[32minstall network bridge\e[0m";
#bridge#sudo apt install -y bridge-utils


######################################################################
echo -e "\e[32minstall iptables for network address translation (NAT)\e[0m";
echo "iptables-persistent     iptables-persistent/autosave_v4 boolean true" | sudo debconf-set-selections;
echo "iptables-persistent     iptables-persistent/autosave_v6 boolean true" | sudo debconf-set-selections;
sudo apt install -y iptables iptables-persistent


######################################################################
$(dpkg --get-selections | grep -q -E "^(ntp|ntpd)[[:blank:]]*install$") || {
echo -e "\e[32minstall chrony as ntp client and ntp server\e[0m";
sudo apt install -y chrony;
sudo systemctl enable chronyd.service;
sudo systemctl restart chronyd.service;
}

######################################################################
######################################################################


######################################################################
## optional
echo -e "\e[32minstall tshark\e[0m";
echo "wireshark-common        wireshark-common/install-setuid boolean true" | sudo debconf-set-selections;
sudo apt install -y tshark
sudo usermod -a -G wireshark $USER

echo -e "\e[32minstall other useful stuff\e[0m";
sudo apt install -y xterm transmission-gtk

echo -e "\e[32mreduce annoying networktraffic\e[0m";
sudo systemctl stop avahi-daemon.service
sudo systemctl disable avahi-daemon.service
sudo systemctl stop minissdpd.service
sudo systemctl disable minissdpd.service


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
sudo sh -c "echo '########################################
## mod_install_server
dtparam=audio=on

max_usb_current=1
#force_turbo=1

disable_overscan=1
hdmi_force_hotplug=1
config_hdmi_boost=4

hdmi_ignore_cec_init=1
cec_osd_name=PXE-Server

#########################################
# standard resolution
#hdmi_drive=2

#########################################
# custom resolution
# 4k@24Hz or 25Hz custom DMT - mode
gpu_mem=128
hdmi_group=2
hdmi_mode=87
hdmi_pixel_freq_limit=400000000
max_framebuffer_width=3840
max_framebuffer_height=2160

    #### implicit timing ####
    #hdmi_cvt 3840 2160 24
    ##hdmi_cvt 3840 2160 25

    #### explicit timing ####
    #hdmi_ignore_edid=0xa5000080
    hdmi_timings=3840 1 48 32 80 2160 1 3 5 54 0 0 0 24 0 211190000 3
    ##hdmi_timings=3840 1 48 32 80 2160 1 3 5 54 0 0 0 25 0 220430000 3
    #framebuffer_width=3840
    #framebuffer_height=2160
' > /boot/config.txt"
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
[ -f /etc/ssh/mod_install_server ] || [ -d $SRC_MOUNT/backup/ssh/ ] && {
echo -e "\e[32mcopy predefined ssh keys\e[0m";
sudo touch /etc/ssh/mod_install_server
sudo rsync -xa --info=progress2 $SRC_MOUNT/backup/ssh/* /etc/ssh/
sudo chmod 0600 /etc/ssh/*key
sudo ssh-keygen -A
sudo systemctl disable regenerate_ssh_host_keys.service
# sudo rm -f /etc/systemd/system/multi-user.target.wants/regenerate_ssh_host_keys.service
}


######################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
