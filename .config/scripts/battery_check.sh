#!/bin/bash
while true; do
    bat_lvl=$(cat /sys/class/power_supply/BAT0/capacity)
    bat_status=$(cat /sys/class/power_supply/BAT0/status)
    if [ "$bat_lvl" -le 20 ] && [ "$bat_status" == "Discharging" ]; then
        notify-send -u critical "Battery Low" "Battery is at $bat_lvl%. Please plug in!"
        sleep 300 # Wait 5 minutes before reminding again
    fi
    sleep 60 # Check every minute
done
