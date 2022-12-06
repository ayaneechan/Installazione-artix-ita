# ARTIX INSTALLAZIONE MANUALE [![](https://img.shields.io/badge/Artix-Linux%20OS-blue?style=for-the-badge&logo=Artix+Linux)](https://artixlinux.org/)
 ### OpenRc | ext4 | mate-desktop | Copyleft (ↄ) Aya Corona 2022

## Prerequisiti:

- Live-usb con artix (https://artixlinux.org/download.php) User `artix` Password `artix`
- Connessione ad internet 

### Impostare il layout della tastiera
Per verificare i tipi di layout disponibili: 
```
 ls -R /usr/share/kbd/keymaps
```
Digitare quindi il nome del layout senza l'estensione. Ad esempio, per impostare il layout italiano(Italia), digitare: 
```
 loadkeys it
```
Questo imposta il layout di tastiera selezionato solo nella tty corrente e solo fino al riavvio. Per rendere permanente l'impostazione, è necessario modificare /etc/conf.d/keymaps nel sistema installato. 
```
# Use keymap to specify the default console keymap.  There is a complete tree
# of keymaps in /usr/share/keymaps to choose from.
keymap="it"

# Should we first load the 'windowkeys' console keymap?  Most x86 users will
# say "yes" here.  Note that non-x86 users should leave it as "no".
# Loading this keymap will enable VT switching (like ALT+Left/Right)
# using the special windows keys on the linux console.
windowkeys="NO"

# The maps to load for extended keyboards.  Most users will leave this as is.
extended_keymaps=""
#extended_keymaps="backspace keypad euro2"

# Tell dumpkeys(1) to interpret character action codes to be
# from the specified character set.
# This only matters if you set unicode="yes" in /etc/rc.conf.
# For a list of valid sets, run `dumpkeys --help`
dumpkeys_charset=""

# Some fonts map AltGr-E to the currency symbol instead of the Euro.
# To fix this, set to "yes"
```
È utile anche impostare /etc/vconsole.conf, che può essere simile a questo: 
```
 KEYMAP=it
```
## Partitione del disco (BIOS)
### Controllare i dischi disponibili con: `lsblk`
### Partizionare il disco rigido cfdisk: (es. /dev/sda ; /dev/nvme0n1 ; /dev/nvme0n1p1)
- 512MB Efi system  (*minimo)
- 4GB swap          (*minimo)
- il resto filesystem ext4
```
 cfdisk /dev/sda
```
### Formattare le partizioni
Partizione di boot
```
 mkfs.fat -F 32 /dev/sda1
```
```
 fatlabel /dev/sda1 BOOT
```
Partizione di swap
```
 swapon /dev/disk/sda2/SWAP      
```
Partizione di root
```
 mkfs.ext4 -L ROOT /dev/sda3
```
### Montare le partizioni
Montare partizione di swap
```
 mkswap -L SWAP /dev/sda2
```
Montare partizione di root
```
 mount /dev/disk/by-label/ROOT /mnt
```
Creare directory boot
```
  mkdir /mnt/boot 
```
Montare directory boot
```
 mount /dev/disk/sda1/BOOT /mnt/boot 
```
### Connettere ad Internet
Per controllo
```
 ping artixlinux.org
```
### Aggiornare l'orologio di sistema
Attivare il demone NTP per sincronizzare l'orologio in tempo reale del computer
```
 rc-service ntpd start
```
### Installare il sistema di base
Usare basestrap per installare i pacchetti base e l'init preferito `openrc`
```
 basestrap /mnt base base-devel openrc elogind elogind-openrc
```
In caso di errori usare
```
 basestrap -i /mnt base
```
### Installare il kernel
Disponibili sono: `linux` `linux-lts` `linux-zen`
```
 basestrap /mnt linux linux-headers linux-firmware
```
Generate `/etc/fstab`; verificate anche le partizioni `root` `swap` `ecc`
```
 fstabgen -U /mnt >> /mnt/etc/fstab      
```
Montare la partizione di root
```
 artix-chroot /mnt
```
## Configurare il sistema di base
### Configurare l'orologio di sistema
Settare il fuso orario
```
 ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```
Generare `/etc/adjtime` con
```
hwclock --systohc
```
### Localizzazione
Installare un text editor
```
 pacman -S nano
```
Decommentare il locale desiderato
```
nano /etc/locale.gen
```
Generare il locale
```
 locale-gen
```
Per impostare il locale a livello di sistema, creare o modificare /etc/locale.conf
```
 export LANG="it_IT.UTF-8"
 export LC_COLLATE="C"
```
### Bootloader
Installare `grub`; in presenza di alti OS `os-prober`
```
 pacman -S grub efibootmgr
```
In presenza di alti OS installare `os-prober`
```
pacman -S os-prober
```
Per sistemi UEFI
```
 grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub 
```
Per sistemi BIOS
```
 grub-install --recheck /dev/sda        
```
### Abilitare i microcode `INTEL` o `AMD` in base al vostro processore
INTEL
```
pacman -S intel-ucode
```
AMD 
```
pacman -S amd-ucode
```
### Utenti
Password di root 
```
 passwd
```
Creare un utente regolare es. UTENTE
```
 useradd -mG wheel UTENTE
```
Impostare la password
```
 passwd UTENTE
```
Aggiungere i permessi di root
```
EDITOR=nano visudo
```
#Togliere il cancelletto da %wheel ALL=(ALL) ALL
### Configurazione di rete
Creare documento di host `nano /etc/hostname`
```
 vostrohostname
```
Modificare gli host `nano /etc/hosts`
```
 127.0.0.1        localhost
 ::1              localhost
 127.0.1.1        vostrohostname.localdomain  vostrohostname
```
Modificare le configurazioni `/etc/conf.d/hostname`
```
hostname='vostrohostname'
```
Installare il client DHCP e le connessioni wireless
```
 pacman -S dhcpcd wpa_supplican
```
Installare connman
``` 
pacman -S connman-openrc connman-gtk
```
Aggiungere il servizio
```
 rc-update add connmand
```
### Riavviare il sistema
Uscire da chroot
```
exit
```
Smontare il sistema
```
umount -R /mnt
```
Riavvio
```
reboot
```
## Configurazione post-installazione
### Aggiungere le repo universe
Modificare `/etc/pacman.conf`
```
sudo nano /etc/pacman.conf
```
In fondo al file aggiungere:
```
[universe]
Server = https://universe.artixlinux.org/$arch
Server = https://mirror1.artixlinux.org/universe/$arch
Server = https://mirror.pascalpuffke.de/artix-universe/$arch
Server = https://artixlinux.qontinuum.space/artixlinux/universe/os/$arch
Server = https://mirror1.cl.netactuate.com/artix/universe/$arch
Server = https://ftp.crifo.org/artix-universe/
```
Aggiornare le repo
```
sudo pacman -Syu 
```
Aggiungere il supporto ad arch
```
sudo pacman -S artix-archlinux-support
```
Aggiungere le repo di arch
```
sudo nano /etc/pacman.conf
```
In fondo al file aggiungere:
```
#Archlinux
[extra]
Include = /etc/pacman.d/mirrorlist-arch

[community]
Include = /etc/pacman.d/mirrorlist-arch
```
Aggiornare le repo
```
sudo pacman -Syu 
```
Installare le utility audio
```
pacman -S pipewire pipewire-pulse alsa-utils
```
Installare l'ambiente grafico
```
sudo pacman -S xorg xf86-video-amdgpu lightdm lightdm-openrc lightdm-gtk-greeter mate mate-extra system-config-printer connman-gtk
```
Attivate il vostro display manager
```
sudo rc-update add lightdm default
```
### Riavviate e divertitevi
## Alcuni programmi utili:
### Gnome disks (gestione dischi)
```
sudo pacman -S gnome-disk-utility
```
### Pamac (gestore software)
```
sudo pacman -S pamac
```
### Dino (xmpp client)
```
sudo pacman -S dino
```
### Kleopatra (chiavi openPGP)
```
sudo pacman -S kleopatra
```
### Telegram
```
sudo pacman -S telegram-desktop
```
### Libreoffice (office)
```
sudo pacman -S libreoffice
```
### Mpv (video player)
```
sudo pacman -S mpv
```
### Freetube (client YT privato)
```
sudo pacman -S freetube
```
### Evolution (mail manager)
```
sudo pacman -S evolution
```
### Librewolf (Browser privato)
```
sudo pacman -S librewolf
```
