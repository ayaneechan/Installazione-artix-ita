# ARTIX INSTALLAZIONE MANUALE
- OpenRc 
- ext4
- mate-desktop

[![](https://img.shields.io/badge/Artix-Linux%20OS-blue?style=for-the-badge&logo=Artix+Linux)](https://artixlinux.org/)
> Copyleft (ↄ) Aya Corona 2022

## Nuova installazione di Artix da un supporto avviabile

Artix può essere installato tramite la console o installer. L'installazione tramite installer è abbastanza semplice, ma noi effettueremo la procedura di installazione tramite console. Le immagini di installazione sono confermate per funzionare sia su sistemi BIOS che UEFI. 

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
 # FONT_MAP=8859-1_to_uni
 # FONT=lat1-16
 KEYMAP=it
```
## Partitione del disco (BIOS)
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
Installare il sistema di base
```
 basestrap /mnt base base-devel openrc elogind-openrc
```
Aggiornare l'orologio di sistema
```
 rc-service ntpd start
```
### togliere immediatamente la chiavetta usb *consigliato

# Configurazione post-installazione

### Modificare il file e aggiungere le repo dopo [galaxy] | basta un server solo
```
[universe]
Server = https://universe.artixlinux.org/$arch
Server = https://mirror1.artixlinux.org/universe/$arch
Server = https://mirror.pascalpuffke.de/artix-universe/$arch
Server = https://artixlinux.qontinuum.space/artixlinux/universe/os/$arch
Server = https://mirror1.cl.netactuate.com/artix/universe/$arch
Server = https://ftp.crifo.org/artix-universe/
```
### Aggiornare le repo
```
sudo pacman -Syu 
```
### Aggiungere il supporto ad arch
```
sudo pacman -S artix-archlinux-support
```
## aggiungere le repo di https://wiki.artixlinux.org/Main/Repositories
```
sudo nano /etc/pacman.conf
```
### aggiungere in fondo al file o dopo le repo #Artix per non creare confusione
```
#Archlinux
[extra]
Include = /etc/pacman.d/mirrorlist-arch

[community]
Include = /etc/pacman.d/mirrorlist-arch
```
### Aggiornare le repo
```
sudo pacman -Syu 
```
### Installare un text editor (artix consiglia 'nano')
```
sudo pacman -S nano
```
### Per sicurezza installare questi pacchetti
```
sudo pacman dialog dosfstools 
```
### Installare le utility audio
```
pacman -S pipewire pipewire-pulse alsa-utils
```
### Aggiungere proprio utente (es. sonozoccola)
```
useradd -mG wheel sonozoccola
```
```
passwd sonozoccola
```
### Aggiungere i permessi di root
```
EDITOR=nano visudo
```
### Togliere il cancelletto da %wheel ALL=(ALL) ALL

### Installiamo la parte grafica; se sapete cosa state facendo potete non installare alcuni paccheti inutili (altrimenti no)
```
sudo pacman -S xorg xf86-video-amdgpu lightdm-openrc lightdm-gtk-greeter mate mate-extra system-config-printer connman-gtk
```
### Attivate il vostro display manager
```
sudo rc-update add lightdm default
```

# Riavviate e divertitevi
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
