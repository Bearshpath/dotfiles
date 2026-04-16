#!/bin/bash

# 1. Toggle the workspace mode
hyprctl dispatch workspaceopt allfloat

# 2. Check if we just switched TO floating mode
IS_FLOATING=$(hyprctl activeworkspace -j | jq '.hasfloating')

if [ "$IS_FLOATING" = "true" ]; then
    # When windows come out of 'Tile' mode, they are stuck at 50% width.
    # We tell the active window to snap to a 'State B' size (80% of screen) 
    # so it feels like a normal floating window again.
    hyprctl dispatch resizeactive exact 85% 80%
    hyprctl dispatch centerwindow
else
    # If we are going back to Tiling, Hyprland handles the 50/50 split automatically.
    notify-send -t 1000 "Layout" "Tiling Mode (50/50)"
fi
