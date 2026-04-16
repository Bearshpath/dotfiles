#!/bin/bash

# 1. Handle command
case $1 in
    up) brightnessctl set 5%+ ;;
    down) brightnessctl set 5%- ;;
esac

# 2. Get current brightness %
# This magic command extracts just the number (e.g., 60)
BRIGHTNESS=$(brightnessctl -m | cut -d, -f4 | tr -d %)

# 3. Send Notification with Bar
notify-send -r 2594 -h int:value:"$BRIGHTNESS" "Brightness: ${BRIGHTNESS}%"
