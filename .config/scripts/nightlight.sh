#!/bin/bash

# File to store the current temperature
TEMP_FILE="/tmp/hyprsunset_current_temp"
DEFAULT=4000

function get_current_temp {
    if [ -f "$TEMP_FILE" ]; then
        cat "$TEMP_FILE"
    else
        echo "$DEFAULT"
    fi
}

case "$1" in
    toggle)
        if pgrep -x "hyprsunset" > /dev/null; then
            pkill hyprsunset
            rm -f "$TEMP_FILE"
            notify-send "Night Light" "OFF" -t 2000
        else
            echo "$DEFAULT" > "$TEMP_FILE"
            hyprsunset -t "$DEFAULT" &
            notify-send "Night Light" "ON ($DEFAULT K)" -t 2000
        fi
        ;;
    inc)
        # Check if running first
        if ! pgrep -x "hyprsunset" > /dev/null; then
             notify-send "Night Light" "Please toggle ON first" -t 2000
             exit 0
        fi

        current=$(get_current_temp)
        # Increase (Cooler)
        new_temp=$((current + 500))
        if [ "$new_temp" -gt 10000 ]; then new_temp=10000; fi

        echo "$new_temp" > "$TEMP_FILE"
        pkill hyprsunset
        sleep 0.1 # Wait for it to close completely
        hyprsunset -t "$new_temp" &
        notify-send "Night Light" "${new_temp}K" -t 1000
        ;;
    dec)
        # Check if running first
        if ! pgrep -x "hyprsunset" > /dev/null; then
             notify-send "Night Light" "Please toggle ON first" -t 2000
             exit 0
        fi

        current=$(get_current_temp)
        # Decrease (Warmer)
        new_temp=$((current - 500))
        if [ "$new_temp" -lt 1000 ]; then new_temp=1000; fi

        echo "$new_temp" > "$TEMP_FILE"
        pkill hyprsunset
        sleep 0.1 # Wait for it to close completely
        hyprsunset -t "$new_temp" &
        notify-send "Night Light" "${new_temp}K" -t 1000
        ;;
esac
