#!/bin/bash

# Check the name of the current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | grep '"name":' | awk -F '"' '{print $4}')

if [ "$CURRENT_WS" = "Desktop" ]; then
    # If we are already on Desktop, go back to the previous workspace
    hyprctl dispatch workspace previous
else
    # If we are working, switch to the clean "Desktop" workspace
    hyprctl dispatch workspace name:Desktop
fi
