# PiStream

## Kurzbeschreibung
PiStream ist ein System für Heim-Streaming ins Wohnzimmer für das Raspberry Pi 5. Dieses Repository stellt eine Ansible-Rolle bereit, die PiStream auf einem bereits vorhandenen Raspberry Pi OS installiert. PiStream, das auf einem Zusammenspiel von verschiedener Open Source Software basiert, ermöglicht die Nutzung des Chromium-Browsers, Game- bzw. Desktop-Streaming über [Moonlight](https://moonlight-stream.org/) und des [Jellyfin](https://jellyfin.org) Clients für die eigene Medienbibliothek direkt am Fernseher.

## Voraussetzungen

1. Jellyfin-Server zu dem sich der Client des PiStream verbinden kann
2. Rechner mit [Sunshine](https://app.lizardbyte.dev/Sunshine/) (oder vergleichbarer Streaming-Software)
3. Raspberry Pi 5 mit funktionaler SSH-Konfiguration (benötigt für Ansible)
4. Headless Raspberry Pi OS (Raspberry Pi OS Lite)

## Features

1. Moonlight Game-Streaming
2. Kiosk-Style Startmenü für verschiedene Funktionen
3. Browser für alltägliches Surfen oder z.B. Youtube-Videos
4. Plug-and-Play
5. Automatische Installation mit Ansible

## Setup

1. Auf dem Hauptrechner ein SSH-Schlüsselpaar erzeugen
```
ssh-keygen
```
2. Raspberry Pi OS Lite (ohne Desktop) auf dem Raspberry Pi 5 installieren
    * Raspberry Pi Imager herunterladen
    * Öffentlichen Schlüssel für SSH voreinstellen (z.B. Inhalt von `~/.ssh/id_rsa.pub`)
    * Nutzer-Konfiguration voreinstellen
    * SD-Karte bespielen und ins Raspberry Pi einsetzen

3. SSH für `root` konfigurieren
    * Raspberry Pi mit dem Netzwerk verbinden und einschalten
    * IP-Adresse des Raspberry Pi herausfinden
        * Option 1: Bildschirm anschließen - Die IP-Adresse wird in der Login-Maske angezeigt
        * Option 2: Im DHCP-Server nachschauen - Der Heimrouter weiß, welche Geräte sich im Netzwerk befinden
    * Vom Hauptrechner eine SSH-Verbindung zum Raspberry Pi herstellen und Root-Zugriff einrichten
```
ssh <voreingestellter_Nutzername>@<IP-Adresse des Pi>
```
```
sudo mkdir /root/.ssh && \
sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys &&\
sudo chown -R root:root /root
```
4. Ansible-Rolle ausführen
    * Ansible auf dem Hauptrechner installieren, falls noch nicht geschehen: `sudo apt install ansible`
    * Am Hauptrechner in das `ansible/`-Verzeichnis des Repositories wechseln
    * Die in der Datei `inventory` hinterlegte IP-Adresse auf die des Pi setzen und speichern
```
ansible-playbook -i inventory playbook.yml
```


## ToDo / Soon(tm):

1. Auto-Updates
2. Look & Feel

## Disclaimer

PiStream ist ein Hobby-Projekt und funktioniert möglicherweise ganz gut oder halt auch nicht. Ich übernehme keine Verantwortung für irgendwelche Probleme, die aus der Nutzung des Systems resultieren und biete keine Unterstützung an. 