#!/bin/bash

# 1. Check current status of blur (0 is disabled, 1 is enabled)
# We use jq to parse the JSON output from hyprctl
STATUS=$(hyprctl getoption decoration:blur:enabled -j | jq '.int')

if [ "$STATUS" -eq 1 ]; then
    # --- SWITCH TO SOLID MODE ---
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0
    notify-send "Hyprland" "Solid Mode: Blur Disabled" -t 1000
else
    # --- SWITCH TO GLASS MODE ---
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:blur:size 5
    hyprctl keyword decoration:blur:passes 3
    hyprctl keyword decoration:active_opacity 0.97
    hyprctl keyword decoration:inactive_opacity 0.97
    notify-send "Hyprland" "Glass Mode: Blur Enabled" -t 1000
fi
