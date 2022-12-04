# ARTIX INSTALLAZIONE
[![](https://img.shields.io/badge/Artix-Linux%20OS-blue?style=for-the-badge&logo=Artix+Linux)](https://artixlinux.org/)

## Installazione via shell del sistema base
- Avviare il boot da Artix live usb (LOGIN & PASS = artix)
- Connettere il sistema ad internet
- Aprire gparted o disks e formattare il sistema
- Avviare il terminale ed evitare l'auto installazione buggata

### Aquisire lo script di installazione, estrarre ed entrare nella cartella estratta
```
curl -OL https://github.com/ayaneechan/artix-ita/archive/artix-ita-v1.0.tar.gz
```
```
tar xzf v1.0.tar.gz
```
```
cd artix-ita-v1.0.tar.gz
```
```
bash ./install.sh
```
ora aspettate (deve scaricare tutti i pacchetti), infine riavviate
```
sudo reboot
```
### Primo avvio
Impostate lightdm
```
sudo rc-update add lightdm default
```
Riavvio
```
sudo reboot
```
## Configurazione post-installazione
### Per loggare 
>Utente=root <br />
>Password=la vostra password
### Ora entrate nel terminale per le ultime configurazioni
Aprite il file di configurazione di pacman
```
sudo nano /etc/pacman.conf
```
Modificare il file e aggiungere le repo dopo [galaxy]
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
### Aggiungere proprio utente (es. sonozoccola)
```
useradd -mG wheel sonozoccola
```
```
passwd sonozoccola
```
### Aggiungere i permessi di root al vostro utente
```
EDITOR=nano visudo
```
Togliere il cancelletto da %wheel ALL=(ALL) ALL
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
