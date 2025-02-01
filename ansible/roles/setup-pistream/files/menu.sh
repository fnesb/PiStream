#!/bin/bash
# Felix Nesbigall - 01.02.2025
# Displays streaming menu in openbox using rofi

while true; do

    CHOICE=$(echo -e "Movie Library\nStream Desktop\nBrowser\nSettings\nShutdown" | rofi -dmenu -p "PiStream" -i)

    case "$CHOICE" in
        "Movie Library")
            echo "Movie Library"
            ;;
        "Stream Desktop")
            echo "Stream Desktop"
            ;;
        "Browser")
            echo "Browser"
            ;;
        "Settings")
            SETTINGS_CHOICE=$(echo -e "Bluetooth\nNetwork\nShow Devices\nBack" | rofi -dmenu -p "Settings" -i)
            case "$SETTINGS_CHOICE" in
                "Bluetooth")
                    include bluetooth-settings.sh
                    ;;
                "Network")
                    include network-settings.sh
                    ;;
                "Show Devices")
                    include show-devices.sh
                    ;;
                "Back")
                    ;;
            esac
            ;;
        "Shutdown")
            echo "Shutdown"
            ;;
    esac
    