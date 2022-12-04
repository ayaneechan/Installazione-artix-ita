#!/bin/sh -e
#
# Un installer per Artix Linux
# 
# Copyright (c) 2022 Aya Corona
#
# Licenza Pubblica Generale GNU General Public License

# Partizione disco
if [[ $my_fs == "ext4" ]]; then
    layout=",,V"
    fs_pkgs="lvm2 lvm2-$my_init"
elif [[ $my_fs == "btrfs" ]]; then
    layout=",$(echo $swap_size)G,S\n,,L"
    fs_pkgs="btrfs-progs"
fi
[[ $encrypted == "y" ]] && fs_pkgs+=" cryptsetup cryptsetup-$my_init"

printf "label: gpt\n,550M,U\n$layout\n" | sfdisk $my_disk

# Formattazione e montaggio partitioni
if [[ $encrypted == "y" ]]; then
    yes $cryptpass | cryptsetup -q luksFormat $root_part
    yes $cryptpass | cryptsetup open $root_part root

    if [[ $my_fs == "btrfs" ]]; then
        yes $cryptpass | cryptsetup -q luksFormat $part2
        yes $cryptpass | cryptsetup open $part2 swap
    fi
fi

mkfs.fat -F 32 $part1

if [[ $my_fs == "ext4" ]]; then
    # Setup LVM
    pvcreate $my_root
    vgcreate MyVolGrp $my_root
    lvcreate -L $(echo $swap_size)G MyVolGrp -n swap
    lvcreate -l 100%FREE MyVolGrp -n root

    mkfs.ext4 /dev/MyVolGrp/root

    mount /dev/MyVolGrp/root /mnt
elif [[ $my_fs == "btrfs" ]]; then
    mkfs.btrfs $my_root

    # Creazione subvolumi
    mount $my_root /mnt
    btrfs subvolume create /mnt/root
    btrfs subvolume create /mnt/home
    umount -R /mnt

    # Montaggio subvolumi
    mount -t btrfs -o compress=zstd,subvol=root $my_root /mnt
    mkdir /mnt/home
    mount -t btrfs -o compress=zstd,subvol=home $my_root /mnt/home
fi

mkswap $my_swap
mkdir /mnt/boot
mount $part1 /mnt/boot

[[ $(grep 'vendor' /proc/cpuinfo) == *"Intel"* ]] && ucode="intel-ucode"
[[ $(grep 'vendor' /proc/cpuinfo) == *"Amd"* ]] && ucode="amd-ucode"

# Installazione sistema e kernel
basestrap /mnt base base-devel $my_init elogind elogind-$my_init $fs_pkgs efibootmgr grub $ucode dhcpcd wpa_supplicant connman-$my_init pipewire pipewire-pulse alsa-utils xorg xf86-video-amdgpu lightdm-openrc lightdm-gtk-greeter mate mate-extra system-config-printer connman-gtk
basestrap /mnt linux-zen linux-zen-headers linux linux-headers linux-firmware mkinitcpio
fstabgen -U /mnt > /mnt/etc/fstab
rc-update add lightdm default
