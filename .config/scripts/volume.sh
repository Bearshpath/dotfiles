#!/bin/bash

# 1. Handle the command
case $1 in
    up) pamixer -i 5 ;;
    down) pamixer -d 5 ;;
    mute) pamixer -t ;;
esac

# 2. Get current volume and mute status
VOLUME=$(pamixer --get-volume)
IS_MUTED=$(pamixer --get-mute)

# 3. Send Notification with Progress Bar
# -h int:value:$VOLUME creates the slider bar
# -t 1000 makes it disappear after 1 second
# -r 2593 ensures the notification replaces the old one (smooth animation)

if [ "$IS_MUTED" = "true" ]; then
    notify-send -r 2593 -u low "Volume" "Muted"
else
    notify-send -r 2593 -h int:value:"$VOLUME" "Volume: ${VOLUME}%"
fi
