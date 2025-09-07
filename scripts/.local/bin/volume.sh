#!/bin/bash

# You can customize this script

# Function to send a notification for output volume
send_notification() {
    icon_path=/home/asif/.local/share/icons/McMojave-circle/status/32/
    volume=$(pamixer --get-volume)
    is_muted=$(pamixer --get-mute)

    if [ "$is_muted" = "true" ]; then
        notify-send -a "volume-notification" -u low " Muted"
    else
        icon=""
        if [ "$volume" -lt 30 ]; then
            icon=""
        elif [ "$volume" -lt 70 ]; then
            icon=""
        fi
        notify-send -a "volume-notification" -u low -h int:value:"$volume" -h string:x-canonical-private-synchronous:volume "${icon}   ${volume}%"
    fi
}

# Function to send a notification for input volume (mic)
send_mic_notification() {
    is_mic_muted=$(pamixer --default-source --get-mute)

    if [ "$is_mic_muted" = "true" ]; then
        icon="microphone-disabled-symbolic"
        notify-send -i $icon -u low "Microphone Muted"
    else
        icon="microphone-sensitivity-high-symbolic"
        notify-send -i $icon -u low "Microphone On"
    fi
}


case $1 in
    raise)
        pamixer --allow-boost -i 5
        send_notification
        ;;
    lower)
        pamixer -d 5
        send_notification
        ;;
    mute-toggle)
        pamixer -t
        send_notification
        ;;
    mic-mute-toggle)
        pamixer --default-source -t
        send_mic_notification
        ;;
    *)
        echo "Usage: $0 {raise|lower|mute-toggle|mic-mute-toggle}"
        exit 1
        ;;
esac
