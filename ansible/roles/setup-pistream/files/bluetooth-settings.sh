#!/bin/bash
# Felix Nesbigall - 01.02.2025
# PiStream Bluetooth menu


bluetoothctl scan on
while true; do

    CHOICE=$(echo -e "Pair Device\nRemove Device\nList Paired Devices\nBack" | rofi -dmenu -p "Bluetooth" -i)

    case "$CHOICE" in
        "Pair Device")
            DEVICE=$(bluetoothctl devices | rofi -dmenu -p "Pair Device" -i)
            bluetoothctl pair $DEVICE
            ;;
        "Remove Device")
            DEVICE=$(bluetoothctl paired-devices | rofi -dmenu -p "Remove Device" -i)
            bluetoothctl remove $DEVICE
            ;;
        "List Paired Devices")
            bluetoothctl paired-devices
            ;;
        "Back")
            bluetoothctl scan off
            break
            ;;
    esac
done

