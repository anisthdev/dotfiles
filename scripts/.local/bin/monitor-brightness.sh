#!/bin/bash

send_notification() {
    percentage="$1"

    icon="󰃠 "
    if [ "$percentage" -lt 30 ]; then
        icon="󰃞 "
    elif [ "$percentage" -lt 70 ]; then
        icon="󰃟 "
    fi

    notify-send -a "brightness-notification" -u low -h int:value:"$percentage" -h string:x-canonical-private-synchronous:brightness "${icon}   ${percentage}%"
}

get_brightness() {
    ddcutil --sleep-multiplier=0.1 getvcp 10 --display 1 2>/dev/null | grep -oP 'current value =\s*\K\d+'
}

set_brightness() {
    ddcutil --sleep-multiplier=0.1 setvcp 10 "$1" --display 1 2>/dev/null
}

case $1 in
    raise)
        current=$(get_brightness)
        new=$((current + 5))
        [ "$new" -gt 100 ] && new=100
        set_brightness "$new"
        send_notification "$new"
        ;;
    lower)
        current=$(get_brightness)
        new=$((current - 5))
        [ "$new" -lt 0 ] && new=0
        set_brightness "$new"
        send_notification "$new"
        ;;
    *)
        echo "Usage: $0 {raise|lower}"
        exit 1
        ;;
esac
