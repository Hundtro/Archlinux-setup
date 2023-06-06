#!/bin/bash

# 
# Prepare partitions
# Connect to Internet
# Set install parameters
# Set packages
# Run script
#

# Install parameters
PT_ROOT='/dev/sdaX'
PT_SWAP='/dev/sdaX'
PT_EFI='/dev/sdaX'
MAKE_SWAP=0
MAKE_DUAL=0

# Setup parameters
USER="user"
HOSTNAME="userpc"
LOCALE="sv_SE.UTF-8"
TIMEZONE="/usr/share/zoneinfo/Europe/Stockholm"
KEYMAP="sv-latin1"

# Packages:System
PACS+=' linux'             #Linux
PACS+=' linux-firmware'    #Linux firmware
PACS+=' archlinux-keyring' #Keyring
PACS+=' sudo'              #Sudo and visudo
PACS+=' intel-ucode'       #Intel microcode
PACS+=' grub'              #GRUB bootloader
PACS+=' efibootmgr'        #For UEFI mode
PACS+=' os-prober'         #For Windows detection
PACS+=' acpi'              #Console power manager
PACS+=' alsa-utils'        #For alsamixer
PACS+=' xorg'              #Basic X environment
PACS+=' xorg-xinit'        #For xinit profile
PACS+=' exfat-utils'       #For exFAT
PACS+=' ntfs-3g'           #For NTFS
PACS+=' bc'                #Console calculator

# Packages:Network
PACS+=' iw'                #Basic wireless tool
PACS+=' wpa_supplicant'    #For WPA/WPA2 networks
PACS+=' dhcpcd'            #DHCP daemon client
PACS+=' netctl'            #Wireless connection manager
PACS+=' dialog'            #For connect via wifi-menu
PACS+=' links'             #Console web browser
PACS+=' wget'              #Console web downloader
PACS+=' wvdial'            #For 3G modem connection
PACS+=' usb_modeswitch'    #For modem mode change
PACS+=' tor'               #Tor
#PACS+=' openconnect'      #Cisco Any Connect vpn client
#PACS+=' rdesktop'         #For RDP connections
PACS+=' firefox'           #Firefox web browser
#PACS+=' qutebrowser'      #Qt web browser
#PACS+=' gst-libav'        #Qutebrowser html5 plugins
#PACS+=' gst-plugins-base' #Qutebrowser html5 plugins
#PACS+=' gst-plugins-good' #Qutebrowser html5 plugins
#PACS+=' gst-plugins-bad'  #Qutebrowser html5 plugins
#PACS+=' gst-plugins-ugly' #Qutebrowser html5 plugins
PACS+=' translate-shell'   #Console google translator

# Packages:Video
PACS+=' mesa'              #For OpenGL
PACS+=' xf86-video-intel'  #Intel video drivers

# Packages:Files
PACS+=' vim'               #Console text editor
PACS+=' ranger'            #Console file manager
PACS+=' mupdf'             #Console pdf viewer
PACS+=' xpdf'              #Qt pdf viewer
PACS+=' feh'               #Console image viewer
PACS+=' p7zip'             #Console archive manager
PACS+=' unrar'             #For rar archives
PACS+=' moc'               #Console music player (mocp)
PACS+=' vlc'               #VLC player
PACS+=' libreoffice-still' #MS Office alternative

# Packages:Dev
PACS+=' git'               #Git version control
PACS+=' gdb'               #GNU Debugger
PACS+=' dia'               #Diagram building tool
PACS+=' cmake'             #CMake build tool
PACS+=' qtcreator'         #IDE For C/C++ and Qt

# Installation
echo '[INFO MESSAGE]Begin install'
echo '[INFO MESSAGE]Check Internet connection'
ping -q -c3 8.8.8.8

if [ $? -ne 0 ];
then
    echo '[ERROR MESSAGE]No Internet connection! Exit.'
	exit 1
else
    echo '[INFO MESSAGE]Internet connection OK!'
fi

echo '[INFO MESSAGE]Set Datetime'
timedatectl set-ntp true

echo '[INFO MESSAGE]Prepare partitions'
mkfs.ext4 $PT_ROOT
mount $PT_ROOT /mnt

if [ $MAKE_SWAP -eq 1 ];
then
    mkswap $PT_SWAP
	swapon $PT_SWAP
fi

if [ $MAKE_DUAL -eq 0 ];
then
	mkfs.fat -F 32 $PT_EFI
fi

mkdir -p /mnt/boot/efi
mount $PT_EFI /mnt/boot/efi

echo '[INFO MESSAGE]Install packages'
pacstrap /mnt base base-devel $PACS

if [ $? -ne 0 ];
then
    echo '[ERROR MESSAGE]Install Error! Exit'
	exit 2
fi

echo '[INFO MESSAGE]Generate fstab'
genfstab -U /mnt >> /mnt/etc/fstab

echo '[INFO MESSAGE]Begin setup'
echo '[INFO MESSAGE]Set timezone'
arch-chroot /mnt ln -sf $TIMEZONE /etc/localtime
echo '[INFO MESSAGE]Sync hardware clock'
arch-chroot /mnt hwclock --systohc --utc

echo "[INFO MESSAGE]Generate locale"
arch-chroot /mnt echo "$LOCALE UTF-8" > /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo LANG=$LOCALE > /etc/locale.conf
arch-chroot /mnt echo KEYMAP=$KEYMAP > /etc/vconsole.conf

echo "[INFO MESSAGE]Set hosts"
arch-chroot /mnt echo $HOSTNAME > /etc/hostname
arch-chroot /mnt echo "127.0.1.1 localhost $HOSTNAME" >> /etc/hosts

echo "[INFO MESSAGE]Create User"
arch-chroot /mnt useradd -G wheel -m $USER
echo "[INFO MESSAGE]Enter password for $USER"
arch-chroot /mnt passwd $USER
echo "[INFO MESSAGE]Enter password for root"
arch-chroot /mnt passwd

echo "[INFO MESSAGE]Set up wheel in sudoers"
arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

echo "[INFO MESSAGE]Setup GRUB"
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
if [ $MAKE_DUAL -eq 1 ];
then
	arch-chroot /mnt sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
fi
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "[INFO MESSAGE]Finish"
