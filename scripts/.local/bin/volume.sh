#!/bin/bash

# Volume control with OSD-style notifications

SINK="@DEFAULT_AUDIO_SINK@"
SOURCE="@DEFAULT_AUDIO_SOURCE@"

get_volume() {
    wpctl get-volume "$SINK" | awk '{print int($2 * 100)}'
}

get_icon() {
    local vol=$1
    local muted=$2
    if [ "$muted" = "1" ]; then
        echo " "
    elif [ "$vol" -lt 33 ]; then
        echo ""
    elif [ "$vol" -lt 66 ]; then
        echo " "
    else
        echo "󰕾 "
    fi
}

notify() {
    local vol=$(get_volume)
    local muted=$(wpctl get-mute "$SINK" | awk '{print $2}')
    local icon=$(get_icon "$vol" "$muted")
    local message="${vol}"
    
    if [ "$muted" = "1" ]; then
        message="$icon Muted"
    fi
    
    # OSD-style notification for mako
    notify-send -a "volume-notification" -i "/home/asif/.local/share/icons/McMojave-circle/devices/32/battery-profile-powersave.svg" "$message" -h int:value:$vol -h string:x-canonical-private-synchronous:volume
}

case $1 in
    raise)
        wpctl set-volume -l 1.5 "$SINK" 5%+
        # notify
        ;;
    lower)
        wpctl set-volume "$SINK" 5%-
        # notify
        ;;
    mute-toggle)
        wpctl set-mute "$SINK" toggle
        # notify
        ;;
    mic-mute-toggle)
        wpctl set-mute "$SOURCE" toggle
        # Mic notifications
        mic_muted=$(wpctl get-mute "$SOURCE" | awk '{print $2}')
        icon="󰍬"
        [ "$mic_muted" = "1" ] && icon="󰍭"
        # notify-send -r 12346 --app-name=volume-notification "$icon Microphone: $([ "$mic_muted" = "1" ] && echo "Muted" || echo "Active")" -h string:x-canonical-private-synchronous:mic
        ;;
    *)
        echo "Usage: $0 {raise|lower|mute-toggle|mic-mute-toggle}"
        exit 1
        ;;
esac
