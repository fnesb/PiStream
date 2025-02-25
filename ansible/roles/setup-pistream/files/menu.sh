#!/bin/bash
# Felix Nesbigall - 01.02.2025
# Displays streaming menu in openbox using rofi

# Settings

LOGFILE=$HOME/pistream-menu.log
CHROMIUM_DEFAULT_OPTS="--enable-features=brotli-encoding,ScrollAnchorSerialization --disable-session-crashed-bubble --disable-infobars"
MAIN_MENU="Browser\nNetflix\nDisney Plus\nAmazon Prime\nDesktop Streaming\nMovie Library\nSettings\nShutdown"
DELETE_THIS=(
    "$HOME/.cache/chromium" 
    "$HOME/.config/chromium/Default/Shortcuts" 
    "$HOME/.config/chromium/Default/Favicons" 
    "$HOME/.config/chromium/Default/Network\ Action\ Predictor" 
    "$HOME/.config/chromium/Default/Local\ Storage" 
    "$HOME/.config/chromium/Default/Reporting\ and\ NEL" 
    "$HOME/.config/chromium/Default/Network\ Persistent\ State" 
    "$HOME/.config/chromium/Default/DIPS" 
    "$HOME/.config/chromium/Default/IndexedDB" 
    "$HOME/.config/chromium/Default/Session\ Storage" 
    "$HOME/.config/chromium/segmentation_platform" 
    "$HOME/.config/chromium/ZxcvbnData/3/ranked_dicts" 
    "$HOME/.config/chromium/ZxcvbnData/3/us_tv_and_film.txt"
)

# Functions

log_message() {
    local message=$1
    local line=$2
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $0 - INFO: in ${FUNCNAME[1]} - Line: $line - $message" | tee -a $LOGFILE | systemd-cat -t pistream
}

log_error() {
    local message=${1:-"An error occurred."}
    local line=$2
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $0 - ERROR: in ${FUNCNAME[1]} - Line: $line - CMD: $BASH_COMMAND - $message" | tee -a $LOGFILE | systemd-cat -t pistream
}

export -f log_message
export -f log_error

# Trap errors

trap 'log_error "" "$LINENO"; exit 1' ERR

# Main

log_message "######## Starting menu.sh ########" $LINENO
log_message "Entering main loop" $LINENO
c=0


MENU_LINES=$(echo -e $MAIN_MENU | wc -l)
while true; do
    c=$((c+1))
    log_message "Main loop iteration $c" $LINENO
    CHOICE=$(echo -e $MAIN_MENU | rofi -dmenu -i -lines $MENU_LINE -no-fixed-num-lines -p "PiStream")

    case "$CHOICE" in
        "Browser")
            log_message "Browser selected" $LINENO
            log_message "Clearing cache..." $LINENO
            log_message "rm -rf ${DELETE_THIS[@]}" $LINENO
            rm -rf ${DELETE_THIS[@]} || log_error "Failed to execute rm -rf $HOME/.cache/chromium: $ERROR_OUTPUT" $LINENO
            log_message "Opening browser..." $LINENO
            ERROR_OUTPUT=$(chromium-browser https://www.youtube.com $CHROMIUM_DEFAULT_OPTS) || log_error "Failed to execute chromium-browser --app=https://www.youtube.com/tv --kiosk: $ERROR_OUTPUT" $LINENO
            ;;
        "Netflix")
            log_message "Netflix selected" $LINENO
            ERROR_OUTPUT=$(chromium-browser --app=https://www.netflix.com --kiosk $CHROMIUM_DEFAULT_OPTS) || log_error "Failed to execute chromium-browser --app=https://www.netflix.com --kiosk: $ERROR_OUTPUT" $LINENO
            ;;
        "Disney Plus")
            log_message "Disney Plus selected" $LINENO
            ERROR_OUTPUT=$(chromium-browser --app=https://www.disneyplus.com --kiosk $CHROMIUM_DEFAULT_OPTS) || log_error "Failed to execute chromium-browser --app=https://www.disneyplus.com --kiosk: $ERROR_OUTPUT" $LINENO
            ;;
        "Amazon Prime")
            log_message "Amazon Prime selected" $LINENO
            ERROR_OUTPUT=$(chromium-browser --app=https://www.amazon.de/gp/video/storefront --kiosk) $CHROMIUM_DEFAULT_OPTS || log_error "Failed to execute chromium-browser --app=https://www.amazon.de/gp/video/storefront --kiosk: $ERROR_OUTPUT" $LINENO
            ;;
        "Desktop Streaming")
            log_message "Desktop Streaming selected" $LINENO
            ERROR_OUTPUT=$(moonlight-qt) || log_error "Failed to execute moonlight-qt: $ERROR_OUTPUT" $LINENO
            ;;
        "Movie Library")
            log_message "Movie Library selected" $LINENO
            ERROR_OUTPUT=$(flatpak run com.github.iwalton3.jellyfin-media-player --fullscreen --tv) || log_error "Failed to execute jellyfin: $ERROR_OUTPUT" $LINENO
            ;;
        "Settings")
            log_message "Settings selected" $LINENO
            log_message "Entering settings loop" $LINENO
            d=0
            while true; do
                d=$((d+1))
                log_message "Settings loop iteration $d" $LINENO
                SETTINGS_CHOICE=$(echo -e "Bluetooth\nNetwork\nShow Devices\nShell\nBack" | rofi -dmenu -p "Settings" -i)
                case "$SETTINGS_CHOICE" in
                    "Bluetooth")
                        log_message "Bluetooth selected" $LINENO
                        ERROR_OUTPUT=$(. ./bluetooth-settings.sh) || log_error "Failed to execute bluetooth-settings.sh: $ERROR_OUTPUT" $LINENO
                        ;;
                    "Network")
                        log_message "Network selected" $LINENO
                        ERROR_OUTPUT=$(. ./network-settings.sh) || log_error "Failed to execute network-settings.sh: $ERROR_OUTPUT" $LINENO
                        ;;
                    "Show Devices")
                        log_message "Show Devices selected" $LINENO
                        ERROR_OUTPUT=$(. ./show-devices.sh) || log_error "Failed to execute show-devices.sh: $ERROR_OUTPUT" $LINENO
                        ;;
                    "Shell")
                        log_message "Shell selected" $LINENO
                        ERROR_OUTPUT=$(lxterminal) || log_error "Failed to execute lxterminal: $ERROR_OUTPUT" $LINENO
                        ;;
                    "Back")
                        log_message "Back selected" $LINENO
                        break
                        ;;
                esac
            done
            ;;
        "Shutdown")
            log_message "Shutdown selected" $LINENO
            ERROR_OUTPUT=$(sudo shutdown -h now) || log_error "Failed to execute sudo shutdown -h now: $ERROR_OUTPUT" $LINENO
            ;;
    esac
done    