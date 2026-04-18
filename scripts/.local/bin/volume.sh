#!/bin/bash

SINK="@DEFAULT_AUDIO_SINK@"
SOURCE="@DEFAULT_AUDIO_SOURCE@"

case $1 in
    raise)
        wpctl set-volume -l 1.5 "$SINK" 5%+
        ;;
    lower)
        wpctl set-volume "$SINK" 5%-
        ;;
    mute-toggle)
        wpctl set-mute "$SINK" toggle
        ;;
    mic-mute-toggle)
        wpctl set-mute "$SOURCE" toggle
        ;;
    *)
        echo "Usage: $0 {raise|lower|mute-toggle|mic-mute-toggle}"
        exit 1
        ;;
esac