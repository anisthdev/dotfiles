#!/bin/bash

# You can customize this script

# Function to send a notification
send_notification() {
    brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    percentage=$((brightness * 100 / max_brightness))
    
    icon="󰃠 "
    if [ "$percentage" -lt 30 ]; then
        icon="󰃞 "
    elif [ "$percentage" -lt 70 ]; then
        icon="󰃟 "
    fi

    notify-send -a "brightness-notification" -u low -h int:value:"$percentage" -h string:x-canonical-private-synchronous:brightness "${icon}   ${percentage}%"
}

case $1 in
    raise)
        brightnessctl set 5%+
        send_notification
        ;;
    lower)
        brightnessctl set 5%-
        send_notification
        ;;
    *)
        echo "Usage: $0 {raise|lower}"
        exit 1
        ;;
esac
