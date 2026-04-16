#!/bin/bash
BAT_PATH=$(ls -d /sys/class/power_supply/BAT* | head -n 1)
LAST_STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)

while true; do
    sleep 2
    # 2>/dev/null ignores errors when laptop is waking up from sleep
    NEW_STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)

    # Only trigger if NEW_STATUS is not empty AND is different from LAST_STATUS
    if [ -n "$NEW_STATUS" ] && [ "$NEW_STATUS" != "$LAST_STATUS" ]; then
        if [ "$NEW_STATUS" = "Charging" ]; then
            notify-send -r 9922 -u normal -t 2000 "⚡ Power Connected" "Battery is charging."
        elif [ "$NEW_STATUS" = "Discharging" ]; then
            notify-send -r 9922 -u normal -t 2000 "🔌 Power Unplugged" "Running on battery."
        fi
        LAST_STATUS="$NEW_STATUS"
    fi
done
