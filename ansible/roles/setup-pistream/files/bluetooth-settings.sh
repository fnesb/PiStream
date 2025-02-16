#!/bin/bash
# Felix Nesbigall - 01.02.2025
# PiStream Bluetooth menu

# Functions

update_device_list() {
    while true; do
        DEVICES=$(bluetoothctl devices | awk '{for (i=2; i<=NF; i++) printf $i " "; print ""}')
        echo -e "$DEVICES" > /tmp/bluetooth_devices
        sleep 2
    done
}

cleanup() {
    kill $update_device_list_pid
    rm /tmp/bluetooth_devices
    bluetoothctl scan off
    notify-send "Bluetooth" "Scanning stopped."
}
trap cleanup EXIT 

# Main

bluetoothctl scan on &
notify-send "Bluetooth" "Scanning for devices..."
update_device_list &
update_device_list_pid=$!

AVAILABLE_DEVICES=$(cat /tmp/bluetooth_devices)
MSG_AVAILABLE_DEVICES=$(cat /tmp/bluetooth_devices | sed 's/^/<span>/;s/$/<\/span>/')
MESSAGE="<b>Available Devices:</b><br>$MSG_AVAILABLE_DEVICES"
CHOICE=$(echo -e "Pair Device\nRemove Device\nList Paired Devices\nBack" | rofi -dmenu -p "Bluetooth" -i -mesg "$MESSAGE")

case "$CHOICE" in
    "Pair Device")
        DEVICE_TO_PAIR=$(echo -e "$AVAILABLE_DEVICES" | rofi -dmenu -p "Select Device to Pair" -i)
        if [ -n "$DEVICE_TO_PAIR" ]; then
            DEVICE_MAC=$(echo "$DEVICE_TO_PAIR" | awk '{print $1}')
            
            bluetoothctl pair "$DEVICE_MAC"
            i=0
            while true; do
                PAIR_STATUS=$(bluetoothctl info "$DEVICE_MAC" | grep "Paired: yes")
                if [ -n "$PAIR_STATUS" ]; then
                    notify-send "Bluetooth" "Device paired successfully."
                    break
                fi
                i=$((i+1))
                dots=$(printf "%0.s." $(seq 1 $i))
                rofi -e "Pairing$dots"
                sleep 1
                    if [ $i -eq 30 ]; then
                        notify-send "Bluetooth" "Pairing failed."
                        return 1
                    fi
            done

            bluetoothctl connect "$DEVICE_MAC"
            i=0
            while true; do
                CONNECT_STATUS=$(bluetoothctl info "$DEVICE_MAC" | grep "Connected: yes")
                if [ -n "$CONNECT_STATUS" ]; then
                    notify-send "Bluetooth" "Device connected successfully."
                    break
                fi
                i=$((i+1))
                dots=$(printf "%0.s." $(seq 1 $i))
                rofi -e "Connecting$dots"
                sleep 1
                if [ $i -eq 30 ]; then
                    notify-send "Bluetooth" "Connection failed."
                    return 1
                fi
            done
        fi
        ;;
    "Remove Device")
            PAIRED_DEVICES=$(bluetoothctl paired-devices | awk '{for (i=2; i<=NF; i++) printf $i " "; print ""}')
            DEVICE_TO_REMOVE=$(echo -e "$PAIRED_DEVICES" | rofi -dmenu -p "Select Device to Remove" -i)
            if [ -n "$DEVICE_TO_REMOVE" ]; then
                DEVICE_MAC=$(echo "$DEVICE_TO_REMOVE" | awk '{print $1}')
                bluetoothctl remove "$DEVICE_MAC"
                 i=0
                while true; do
                    REMOVE_STATUS=$(bluetoothctl info "$DEVICE_MAC" | grep "not available")
                    if [ -n "$REMOVE_STATUS" ]; then
                        notify-send "Bluetooth" "Device removed successfully."
                        break
                    fi
                    i=$((i+1))
                    dots=$(printf "%0.s." $(seq 1 $i))
                    rofi -e "Removing$dots"
                    sleep 1
                    if [ $i -eq 30 ]; then
                        notify-send "Bluetooth" "Removal failed."
                        return 1
                    fi
                done
            fi
        ;;
    "List Paired Devices")
            PAIRED_DEVICES=$(bluetoothctl paired-devices | awk '{for (i=2; i<=NF; i++) printf $i " "; print ""}')
            GO_BACK=$(echo -e "Back" | rofi -dmenu -p "Paired Devices" -i -mesg "$PAIRED_DEVICES")
        ;;
    "Back")
        break
        ;;
esac


