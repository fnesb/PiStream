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

## ToDo / Soon(tm):

1. Auto-Updates
2. Look & Feel

## Disclaimer

PiStream ist ein Hobby-Projekt und funktioniert möglicherweise ganz gut oder halt auch nicht. Ich übernehme keine Verantwortung für irgendwelche Probleme, die aus der Nutzung des Systems resultieren und biete keine Unterstützung an. 