#!/bin/bash
# Felix Nesbigall - 01.02.2025
# PiStream Bluetooth menu

# Functions

update_device_list() {
    log_message "bluetooth-settings.sh - update_device_list(): device list update function called" $LINENO
    while true; do
        DEVICES=$(bluetoothctl devices | awk '{for (i=2; i<=NF; i++) printf $i " "; print ""}')
        echo -e "$DEVICES" > /tmp/bluetooth_devices
        sleep 2
    done
}

cleanup() {
    log_message "bluetooth-settings.sh - cleanup(): Cleanup function called" $LINENO
    kill $update_device_list_pid || log_error "bluetooth-settings.sh - cleanup(): Failed to kill update_device_list_pid" $LINENO
    rm /tmp/bluetooth_devices
    kill $bluetoothscan_on_pid || log_error "bluetooth-settings.sh - cleanup(): Failed to kill bluetoothscan_on_pid" $LINENO
    notify-send "Bluetooth" "Scanning stopped."
    kill $bluetoothscan_on_pid || log_error "bluetooth-settings.sh - cleanup(): Failed to kill bluetoothscan_on_pid" $LINENO
    kill $bluetoothscan_off_pid || log_error "bluetooth-settings.sh - cleanup(): Failed to kill bluetoothscan_off_pid" $LINENO
}


# Trap errors

trap 'log_error "Error on line $LINENO. Exit."; exit 1' ERR
trap cleanup EXIT SIGINT SIGHUP SIGTERM SIGKILL

# Main

bluetoothctl scan on &
bluetoothscan_pid=$!
notify-send "Bluetooth" "Scanning enabled."
log_message "Scanning enabled." $LINENO
update_device_list & || log_error "Failed to start update_device_list"
update_device_list_pid=$!

log_message "Entering scanning loop" $LINENO
i=0
for i in (1..9); do
    dots=$(printf "%0.s." $(seq 1 $i))
    rofi -e "Scanning$dots"
    sleep 1
done

log_message "Entering main loop" $LINENO
e=0
while true; do
    e=$((e+1))
    log_message "Main loop iteration $c" $LINENO
    AVAILABLE_DEVICES=$(cat /tmp/bluetooth_devices)
    MSG_AVAILABLE_DEVICES=$(cat /tmp/bluetooth_devices | sed 's/^/<span>/;s/$/<\/span>/')
    MESSAGE="<b>Available Devices:</b>$MSG_AVAILABLE_DEVICES"
    CHOICE=$(echo -e "Pair Device\nRemove Device\nList Paired Devices\nUpdate List\nBack" | rofi -dmenu -p "Bluetooth" -i -mesg "$MESSAGE")

    case "$CHOICE" in
        "Pair Device")
            log_message "Pair Device selected" $LINENO
            DEVICE_TO_PAIR=$(echo -e "$AVAILABLE_DEVICES" | rofi -dmenu -p "Select Device to Pair" -i)
            if [ -n "$DEVICE_TO_PAIR" ]; then
                DEVICE_MAC=$(echo "$DEVICE_TO_PAIR" | awk '{print $1}')
                log_message "Attempt to pair device $DEVICE_MAC" $LINENO
                bluetoothctl pair "$DEVICE_MAC" || log_error "Failed to pair device $DEVICE_MAC" $LINENO
                i=0
                while true; do
                    PAIR_STATUS=$(bluetoothctl info "$DEVICE_MAC" | grep "Paired: yes")
                    if [ -n "$PAIR_STATUS" ]; then
                        notify-send "Bluetooth" "Device paired successfully."
                        log_message "Pairing successful" $LINENO
                        break
                    fi
                    i=$((i+1))
                    dots=$(printf "%0.s." $(seq 1 $i))
                    rofi -e "Pairing$dots"
                    sleep 1
                        if [ $i -eq 30 ]; then
                            notify-send "Bluetooth" "Pairing failed."
                            log_message "Pairing failed" $LINENO
                            return 1
                        fi
                done
                log_message "Attempt to connect to device $DEVICE_MAC" $LINENO
                bluetoothctl connect "$DEVICE_MAC" || log_error "Failed to connect to device $DEVICE_MAC" $LINENO
                i=0
                while true; do
                    CONNECT_STATUS=$(bluetoothctl info "$DEVICE_MAC" | grep "Connected: yes")
                    if [ -n "$CONNECT_STATUS" ]; then
                        notify-send "Bluetooth" "Device connected successfully."
                        log_message "Connection successful" $LINENO
                        break
                    fi
                    i=$((i+1))
                    dots=$(printf "%0.s." $(seq 1 $i))
                    rofi -e "Connecting$dots"
                    sleep 1
                    if [ $i -eq 30 ]; then
                        notify-send "Bluetooth" "Connection failed."
                        log_message "Connection failed" $LINENO
                        return 1
                    fi
                done
            fi
            ;;
        "Remove Device")
            log_message "Remove Device selected" $LINENO
            PAIRED_DEVICES=$(bluetoothctl paired-devices | awk '{for (i=2; i<=NF; i++) printf $i " "; print ""}')
            DEVICE_TO_REMOVE=$(echo -e "$PAIRED_DEVICES" | rofi -dmenu -p "Select Device to Remove" -i)
            if [ -n "$DEVICE_TO_REMOVE" ]; then
                DEVICE_MAC=$(echo "$DEVICE_TO_REMOVE" | awk '{print $1}')
                log_message "Attempt to remove device $DEVICE_MAC" $LINENO
                bluetoothctl remove "$DEVICE_MAC" || log_error "Failed to remove device $DEVICE_MAC" $LINENO
                i=0
                while true; do
                    REMOVE_STATUS=$(bluetoothctl info "$DEVICE_MAC" | grep "not available")
                    if [ -n "$REMOVE_STATUS" ]; then
                        notify-send "Bluetooth" "Device removed successfully."
                        log_message "Removal successful" $LINENO
                        break
                    fi
                    i=$((i+1))
                    dots=$(printf "%0.s." $(seq 1 $i))
                    rofi -e "Removing$dots"
                    sleep 1
                    if [ $i -eq 30 ]; then
                        notify-send "Bluetooth" "Removal failed."
                        log_message "Removal failed" $LINENO
                        return 1
                    fi
                done
            fi
            ;;
        "List Paired Devices")
            log_message "List Paired Devices selected" $LINENO
            PAIRED_DEVICES=$(bluetoothctl paired-devices | awk '{for (i=2; i<=NF; i++) printf $i " "; print ""}')
            GO_BACK=$(echo -e "Back" | rofi -dmenu -p "Paired Devices" -i -mesg "$PAIRED_DEVICES")
            ;;
        "Update List")
            log_message "Update List selected" $LINENO
            continue
            ;;
        "Back")
            log_message "Back selected" $LINENO
            cleanup || log_error "Failed to run cleanup" $LINENO
            break
            ;;
    esac
done

