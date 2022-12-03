# ARTIX INSTALLAZIONE
[![](https://img.shields.io/badge/OS-Artix%20Linux-white?logo=Artix+Linux)](https://artixlinux.org/)

> Si spiega che tutte le relazioni richiedono un po' di dare e ricevere.  Questo non è corretto. Qualsiasi relazione richiede che si dia, si dia e si dia e alla fine, quando ci si finisce nella tomba esausti, ci viene detto che non abbiamo dato abbastanza. 
>
> Quentin Crisp "Come diventare vergini"

Installazione via shell del sistema base | procedimento semplice
Avviare il boot da Artix live usb (LOGIN & PASS = artix) | Usate una iso con grafica integrata
Connettere il sistema ad internet
Aprire gparted o disks e formattare il sistema
Avviare il terminale ed evitare l'auto installazione buggata

Aquisire lo script di installazione, estrarre ed entrare nella cartella estratta
```
curl -OL https://github.com/ayaneechan/artix_installazione/archive/v1.0.tar.gz
```
```
tar xzf v1.0.tar.gz
```
```
cd v1.0
```

Avviare lo script
```
./install.sh
```

Quando si aprono i comandi | la guida segue openrc, ma nessuno vieta di installare dinit
(openrc/dinit)
```
openrc
```
Disk install to | mettere il disco dove volete installare la distro es. /dev/sda
```
/dev/sda
```
Partizione di swap | si consiglia almeno 4gb o non metterla proprio in caso scrivere 0, io metto 6gb
```
6
```
Filesystem | quello che preferite es. ext4
```
ext4
```
Cryptazione, si o no | io la metto
```
y
```
inserite la vostra password due volte | Regione/Citta
```
Europe/Rome
```
hostname il vostro | es, fag-army
```
fag-army
```
password di root | voi mettetene una sicura ps. potete cambiarla sempre
```
1234
```
ora aspettate, deve scaricare tutti i pacchetti | infine riavviate
```
sudo reboot
```
togliere immediatamente la chiavetta usb | *consigliato

Modificare il file e aggiungere le repo dopo [galaxy] | basta un server solo
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
aggiungere le repo di https://wiki.artixlinux.org/Main/Repositories in particolare arch le altre a piacimento 
```
sudo nano /etc/pacman.conf
```
aggiungere in fondo al file o dopo le repo #Artix per non creare confusione
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
Passiamo ad installare i pacchetti mancanti
```
sudo pacman -S base-devel linux-firmware 
```
Installare un text editor | artix consiglia 'nano'; potere usare anche altri editor come vim ecc.
```
sudo pacman -S nano
```
Installare i Microcode del vostro processore intel o amd

AMD
```
sudo pacman -S amd-ucode
```
Intel
```
sudo pacman -S intel-ucode
```
Per sicurezza anche se dovessero essere presenti installare questi pacchetti
```
sudo pacman wpa_supplicant dialog dosfstools 
```
Installare le utility audio
```
pacman -S pulseaudio alsa-utils
```
Aggiungere proprio utente | es. sonozoccola
```
useradd -mG wheel sonozoccola
```
```
passwd sonozoccola
```
Aggiungere i permessi di root | avete installato 'nano' come editor seguendo la guida, con un altro editor cambiare il comando di conseguenza
```
EDITOR=nano visudo
```
Togliere il cancelletto da %wheel ALL=(ALL) ALL


Installiamo la parte grafica | date si a tutto per convenienza; se sapete cosa state facendo potete non installare alcuni paccheti inutili (altrimenti no)
```
sudo pacman -S xorg xf86-video-amdgpu lightdm-openrc lightdm-gtk-greeter mate mate-extra system-config-printer connman-gtk
```
Installare elogind con relativo pacchetto per la vostra distro | openrc in questo caso
```
pacman -S elogind elogind-openrc
```
Attivate il vostro display manager
```
sudo rc-update add lightdm default
```
