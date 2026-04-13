#!/bin/bash

# Volume control — notifications and sounds handled by sysaud

case $1 in
    raise)           wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    lower)           wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    mute-toggle)     wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    mic-mute-toggle) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
    *)               echo "Usage: $0 {raise|lower|mute-toggle|mic-mute-toggle}"; exit 1 ;;
esac
