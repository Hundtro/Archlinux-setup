#!/bin/bash

#Install parameters
PT_ROOT='/dev/sdaX'
PT_SWAP='/dev/sdaX'
PT_EFI='/dev/sdaX'
MAKE_SWAP=0
MAKE_DUAL=0

#Setup parameters
USER="winter"
HOSTNAME="hytte"
LOCALE="en_GB.UTF-8"
TIMEZONE="/usr/share/zoneinfo/Europe/Warsaw"
KEYMAP="pl"

#Base
PACS+=' linux'
PACS+=' linux-firmware'
PACS+=' linux-headers'
PACS+=' archlinux-keyring'
PACS+=' sudo'
PACS+=' grub'
PACS+=' efibootmgr'
PACS+=' os-prober'
PACS+=' xorg'
PACS+=' xorg-xinit'
PACS+=' iw'
PACS+=' wpa_supplicant'
PACS+=' dhcpcd'
PACS+=' netctl'
PACS+=' networkmanager'
PACS+=' dialog'
PACS+=' vim'
PACS+=' git'
PACS+=' mesa'
#PACS+=' intel-ucode'
#PACS+=' xf86-video-intel'
#PACS+=' vulkan-radeon'

#Other
PACS+=' acpi'
PACS+=' alsa-utils'
PACS+=' exfat-utils'
PACS+=' ntfs-3g'
#PACS+=' bc'
#PACS+=' links'
#PACS+=' wget'
#PACS+=' wvdial'
#PACS+=' usb_modeswitch'
#PACS+=' tor'
#PACS+=' openconnect'
#PACS+=' rdesktop'
PACS+=' firefox'
#PACS+=' qutebrowser'
#PACS+=' gst-libav'
#PACS+=' gst-plugins-base'
#PACS+=' gst-plugins-good'
#PACS+=' gst-plugins-bad'
#PACS+=' gst-plugins-ugly'
PACS+=' translate-shell'
PACS+=' ranger'
PACS+=' mupdf'
PACS+=' xpdf'
PACS+=' feh'
PACS+=' p7zip'
PACS+=' unrar'
#PACS+=' moc'
PACS+=' vlc'
PACS+=' libreoffice-still'
PACS+=' gdb'
#PACS+=' dia'
PACS+=' cmake'
#PACS+=' qtcreator'
#PACS+=' dotnet-runtime'
#PACS+=' dotnet-sdk'
#PACS+=' aspnet-runtime'
PACS+=' discord'

#Installation
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

echo "[INFO MESSAGE]Finalizing setup"
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable gdm

echo "[INFO MESSAGE]Finish"
