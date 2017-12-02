# install-pxe-server
setup a Raspberry Pi as an PXE-Server.

it is a private project i have made for myself.

i did not keeped an eye on network security.

**USE IT AT YOUR OWN RISK.**

## what is it good for?
the scripts installs necessary packages to let your RPi act as a DHCP, TFTP, Samba, NFS, PXE server.
and it will download LiveDVD ISOs you can boot your PXE client (Desktop PC) to.

the script can easely be modified to add additional ISOs or update ISOs if updated ones are available.

it also is able to act as server for NETWORK BOOTING for a Raspberry Pi 3 (see **note4**)

### overview schematic:
```
      ╔══════════╗   ╔═══╗       ╔══════╗╔═════════╗
WAN───╢DSL router╟───╢ s ║       ║RPi-  ╠╣USB-stick║
      ╚══════════╝   ║ w ║       ║PXE-  ║╚═════════╝
                     ║ i ║       ║server║
       ╔══════╗      ║ t ╟───eth0╢──┐   ║
       ║ RPi3 ╟──────╢ c ║       ║  │NAT║       ╔═══════════════════════╗
       ╚══════╝   ┌──╢ h ╟──┐    ║  └───╟eth1───╢ PC3 IP:192.168.250.100║
                  │  ╚═══╝  │    ╚══════╝       ╚═══════════════════════╝
               ╔══╧══╗   ╔══╧══╗
               ║ PC1 ║   ║ PC2 ║
               ╚═════╝   ╚═════╝
```

## requirements
### hardware:
- Raspberry Pi (with LAN)
- SD card (big enough to hold entire ISO images of desired Live DVDs), (e.g. 64GByte)
- USB memory stick (for preloaded iso images), (e.g. 64GByte)
- working network environment with a connection to internet

optional, if your SD card is too small or you dont want to have all the server content on the SD card, you can use the USB memory stick to hold all content. for that you have to do small tiny changes on the scripts.

### software:
- **Raspbian Stretch** or **Raspbina Stretch Lite** (2017-08-16), https://www.raspberrypi.org/downloads/raspbian/)

## installation:
assuming,
- your Raspberry Pi is running Raspbian Stretch (or Lite) from 2017-08-16,
- and has a proper connection to the internet via LAN (eth0).
- and your SD card can hold all the iso images (41GB when you use unmodified script),
- and you have plugged an USB-memory-stick that has the has a label **PXE-Server**
- and the folowing folder structure on the USB memory stick:
```
<mount_point>
└── backup
    ├── img
    └── iso
    
mkdir -p <mount_point>/backup/img
mkdir -p <mount_point>/backup/iso
```

optional structure for win-pe pxe boot
```
<mount_point>
└── backup
    └── tftp
        ├── boot
        └── efi

mkdir -p <mount_point>/backup/tftp/boot
mkdir -p <mount_point>/backup/tftp/efi
```
replace **<mount_point>** with the path, where you mounted your USB stick.

1. run `bash install-pxe-server_pass1.sh` to install necessary packages<br />
(use **_bash_** and do not run it from **_sudo_**)
2. reboot your RPi with `sudo reboot`
3. run `bash install-pxe-server_pass2.sh` to copy/download iso images of LiveDVDs, mount and export them and setup PXE menu according installed images.<br />
(use **_bash_** and do not run it from **_sudo_**)
4. reboot your RPi with `sudo reboot`

done.

## update:
to update your images, update the url in the **install-pxe-server_pass2.sh** file and re-run `bash install-pxe-server_pass2.sh`.
this will download all updated iso files.

## modifying the script:
what you should know, when you make modification to the script...<br />
there are three importent locations for the pxe boot and the pxe menu that must fit. otherwise the pxe menu and the following boot process can not find required files.
1. the ISO or NSF path relative to the TFTP root path.<br />
(on disk `/srv/tftp/iso`, `/srv/tftp/nfs` as symbolik link).
2. the ISO or NFS path relative to the pxe boot menu root path<br />
(on disk `/srv/tftp/menu-bios/iso`, `/srv/tftp/menu-bios/iso` as symbolic link).
3. the ISO or NFS path repative to the nfs root path<br />
(on disk `/srv/iso`, `/srv/nfs`).
```
/
└── srv
    ├── iso    (the real physical location of ISO files)
    ├── nfs    (the real physical location of NFS files or mountpoints)
    | 
    └── tftp       (TFTP root)
        ├── iso    (only a symbolic link to ISO files)
        ├── nfs    (only a symbolic link to NFS files)
        |
        └── menu-bios  (PXE boot menu root for BIOS)
            ├── iso    (only a symbolic link to ISO files)
            └── nfs    (only a symbolic link to NFS files)
```
if you make any changes to your script and/or file stcructure on disk, keep an eye to changes you made and adapt everything to match
pxe menu entries to file structure on disk.

what the root of TFTP and PXE boot menu are, is defined in the **_dnsmasq_** configuration file `/etc/dnsmasq.d/pxe-server`.<br />
the root for NFS are defined in `/etc/exports`.


## note:
the script will copy/download/mount following ISOs:
```
win-pe-x86.iso        # Microsoft Windows PE, can not be downloaded, you have to create by yourself
ubuntu-lts-x64.iso    # Ubuntu LTS
ubuntu-lts-x86.iso
ubuntu-x64.iso        # Ubuntu
ubuntu-x86.iso
ubuntu-nopae.iso      # an old Ubuntu with non-PAE for old PCs
debian-x64.iso        # Debian
debian-x86.iso
gnuradio-x64.iso      # GNU Radio
deft-x64.iso          # DEFT
kali-x64.iso          # Kali Linux
pentoo-x64.iso        # Pentoo Linux
systemrescue-x86.iso  # System Rescue
desinfect-x86.iso     # c't desinfect, is not downloadable, you have to get by yourself
tinycore-x86.iso      # tiny core ~16MB minimal linux.
tinycore-x64.iso      # tiny core ~16MB minimal linux.
rpdesktop-x86.iso     # Raspberry Pi Desktop for x86 PC
clonezilla-x64.iso    # clonezilla
clonezilla-x86.iso
```

the following url files will contain the url of the iso image, where to download, to compare if you have the requested iso already downloaded, to prevent downloading an iso newly, when it is done already.
```
win-pe-x86.url
ubuntu-lts-x64.url
ubuntu-lts-x86.url
ubuntu-x64.url
ubuntu-x86.url
ubuntu-nopae.url
debian-x64.url
debian-x86.url
gnuradio-x64.url
deft-x64.url
kali-x64.url
pentoo-x64.url
systemrescue-x86.url
desinfect-x86.url
tinycore-x86.url
tinycore-x64.url
rpdesktop-x86.url
clonezilla-x64.url
clonezilla-x86.url
```

there is a complete new section, that contains download url for disk images, that contains partitions.
```
e.g.
RPD_LITE=rpi-raspbian-lite
RPD_LITE_URL=https://.../...zip
```

**if you don't want some iso images getting downloaded and mounted, you can comment out lines
e.g.:**
```
######################################################################
# handle_iso  $WIN_PE_X86        $WIN_PE_X86_URL;
# handle_iso  $UBUNTU_LTS_X64    $UBUNTU_LTS_X64_URL;
# handle_iso  $UBUNTU_LTS_X86    $UBUNTU_LTS_X86_URL;
# handle_iso  $UBUNTU_X64        $UBUNTU_X64_URL;
# handle_iso  $UBUNTU_X86        $UBUNTU_X86_URL;
# handle_iso  $UBUNTU_NONPAE     $UBUNTU_NONPAE_URL;
# handle_iso  $DEBIAN_X64        $DEBIAN_X64_URL;
# handle_iso  $DEBIAN_X86        $DEBIAN_X86_URL;
# handle_iso  $GNURADIO_X64      $GNURADIO_X64_URL;
# handle_iso  $DEFT_X64          $DEFT_X64_URL;
# handle_iso  $KALI_X64          $KALI_X64_URL;
# handle_iso  $PENTOO_X64        $PENTOO_X64_URL;
# handle_iso  $SYSTEMRESCTUE_X86 $SYSTEMRESCTUE_X86_URL;
# handle_iso  $DESINFECT_X86     $DESINFECT_X86_URL;
handle_iso  $TINYCORE_x64      $TINYCORE_x64_URL;
handle_iso  $TINYCORE_x86      $TINYCORE_x86_URL;
handle_iso  $RPDESKTOP_X86     $RPDESKTOP_X86_URL;
...
```
**same procedure, if you dont want some disk images getting downloaded and mountet, you can comment out those lines
e.g.:**
```
######################################################################
handle_zip_img  $RPD_LITE  $RPD_LITE_URL;
# handle_zip_img  $RPD_FULL  $RPD_FULL_URL;
```

## note2:
some of the PXE-menu entries has additional parameters, that lets the Live systems boot with german language (keyboard layout).
if you dont like or want, remove those additional parameters just behind the ' --' in the menu entries

## note3:
it is prepared for BIOS, UEFI 32bit and UEFI 64bit boot, but UEFI is not tested yet, because of lack of hardware for UEFI boot

## note4: NETWORK BOOTING for Raspberry Pi 3
the server is prepared for to boot a Raspberry Pi 3 via network.
in the script ```install-pxe-server_pass2.sh```, there is a ```RPI_SN=12345678``` line, change the ```12345678``` to the serial number of the RPi3, that will boot from network. if you have more than one RPi3 for network booting you have to add them by hand to the ```/srv/tftp``` folder.

the script will download Raspbian-Stretch-Lite and prepare it for the RPi3 with the given serial number.

by default, a RPi3 is not enabled for network booting. you have to enable it once.

for more information,

see: [Network Booting](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/net.md)<br/>
see: [Network Boot Your Raspberry Pi](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/net_tutorial.md)
