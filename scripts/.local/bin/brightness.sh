#!/bin/bash

# You can customize this script

case $1 in
    raise)
        brightnessctl set 5%+
        ;;
    lower)
        brightnessctl set 5%-
        ;;
    *)
        echo "Usage: $0 {raise|lower}"
        exit 1
        ;;
esac