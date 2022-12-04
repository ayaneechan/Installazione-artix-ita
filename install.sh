# Un installer per Artix Linux
#
# Copyright (c) 2022 Aya Corona
#
# Questo file fa parte di artix_install.
#
# artix-installazione è software libero: è possibile ridistribuirlo e/o modificarlo
# sotto i termini della GNU General Public License pubblicata dalla
# dalla Free Software Foundation, sia la versione 3 della licenza, sia
# (a vostra scelta) qualsiasi versione successiva.
#
# artix-installazione è distribuito nella speranza che possa essere utile, ma
# SENZA ALCUNA GARANZIA; senza nemmeno la garanzia implicita di
# COMMERCIABILITÀ o IDONEITÀ PER UN PARTICOLARE SCOPO. Si veda la Licenza Pubblica Generale GNU
# General Public License per maggiori dettagli.
#
# Dovreste aver ricevuto una copia della Licenza Pubblica Generica GNU
# insieme ad artix-installer. In caso contrario, vedere <https://www.gnu.org/licenses/>.

confirm_password () {
    local pass1="a"
    local pass2="b"
    until [[ $pass1 == $pass2 && $pass2 ]]; do
        printf "$1: " >&2 && read -rs pass1
        printf "\n" >&2
        printf "confirm $1: " >&2 && read -rs pass2
        printf "\n" >&2
    done
    echo $pass2
}

# Caricamento keymap
sudo loadkeys us

# Controllo la modalità di avvio
[[ ! -d /sys/firmware/efi ]] && printf "Not booted in UEFI mode. Aborting..." && exit 1

# Scelta my_init
until [[ $my_init == "openrc" || $my_init == "dinit" ]]; do
    printf "Init system (openrc/dinit): " && read my_init
    [[ ! $my_init ]] && my_init="openrc"
done

# Selezionamento disco
while :
do
    sudo fdisk -l
    printf "\nDisk to install to (e.g. /dev/sda): " && read my_disk
    [[ -b $my_disk ]] && break
done

part1="$my_disk"1
part2="$my_disk"2
part3="$my_disk"3
if [[ $my_disk == *"nvme"* ]]; then
    part1="$my_disk"p1
    part2="$my_disk"p2
    part3="$my_disk"p3
fi

# Dimensione di swap
until [[ $swap_size =~ ^[0-9]+$ && (($swap_size -gt 0)) && (($swap_size -lt 97)) ]]; do
    printf "Size of swap partition in GiB (4): " && read swap_size
    [[ ! $swap_size ]] && swap_size=4
done

# Scelta filesystem
until [[ $my_fs == "btrfs" || $my_fs == "ext4" ]]; do
    printf "Filesystem (btrfs/ext4): " && read my_fs
    [[ ! $my_fs ]] && my_fs="btrfs"
done

root_part=$part3
[[ $my_fs == "ext4" ]] && root_part=$part2

# Cryptazione si o no
printf "Encrypt? (y/N): " && read encrypted
[[ ! $encrypted ]] && encrypted="n"

my_root="/dev/mapper/root"
my_swap="/dev/mapper/swap"
if [[ $encrypted == "y" ]]; then
    cryptpass=$(confirm_password "encryption password")
else
    my_root=$part3
    my_swap=$part2
    [[ $my_fs == "ext4" ]] && my_root=$part2
fi
[[ $my_fs == "ext4" ]] && my_swap="/dev/MyVolGrp/swap"

# Timezone
until [[ -f /usr/share/zoneinfo/$region_city ]]; do
    printf "Region/City (e.g. 'America/Denver'): " && read region_city
    [[ ! $region_city ]] && region_city="America/Denver"
done

# Nome host
while :
do
    printf "Hostname: " && read my_hostname
    [[ $my_hostname ]] && break
done

# Utente
root_password=$(confirm_password "root password")

installvars () {
    echo my_init=$my_init my_disk=$my_disk part1=$part1 part2=$part2 part3=$part3 \
        swap_size=$swap_size my_fs=$my_fs root_part=$root_part encrypted=$encrypted my_root=$my_root my_swap=$my_swap \
        region_city=$region_city my_hostname=$my_hostname \
        cryptpass=$cryptpass root_password=$root_password
}

printf "\nDone with configuration. Installing...\n\n"

# Installazione
sudo $(installvars) sh src/installer.sh

# Chroot
sudo cp src/iamchroot.sh /mnt/root/ && \
    sudo $(installvars) artix-chroot /mnt /bin/bash -c 'sh /root/iamchroot.sh; rm /root/iamchroot.sh; exit' && \
    printf '\n`sudo artix-chroot /mnt /bin/bash` back into the system to make any final changes.\n\nYou may now poweroff.\n'
