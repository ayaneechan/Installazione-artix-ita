# ##!/bin/sh
# Un installer per Artix Linux; Copyright (c) 2022 Aya Corona
# Questo file fa parte di Installazione-artix-ita. Installazione-artix-ita è software libero: è possibile ridistribuirlo e/o modificarlo sotto i termini della GNU General Public License pubblicata dalla dalla Free Software Foundation, sia la versione 3 della licenza, sia (a vostra scelta) qualsiasi versione successiva. Installazione-artix-ita è distribuito nella speranza che possa essere utile, ma SENZA ALCUNA GARANZIA; senza nemmeno la garanzia implicita di COMMERCIABILITÀ o IDONEITÀ PER UN PARTICOLARE SCOPO. Si veda la Licenza Pubblica Generale GNU General Public License per maggiori dettagli. Dovreste aver ricevuto una copia della Licenza Pubblica Generica GNU insieme ad Installazione-artix-ita. In caso contrario, vedere <https://www.gnu.org/licenses/>.

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

# Formattazione e montaggio partizione
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

# Installazione base di sistema e del kernel
basestrap /mnt base base-devel $my_init elogind-$my_init $fs_pkgs efibootmgr grub $ucode dhcpcd wpa_supplicant connman-$my_init
basestrap /mnt linux linux-headers linux-zen linux-zen-headers linux-firmware mkinitcpio
fstabgen -U /mnt > /mnt/etc/fstab
