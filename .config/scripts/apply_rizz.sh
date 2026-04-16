#!/bin/bash
# 1. Run WallRizz to change wallpaper and generate colors
WallRizz -r -d ~/Desktop/wallpapers

# 2. Find the newest color file WallRizz just made
LATEST_CONF=$(ls -t ~/.cache/WallRizz/themes/hyprland@5hubham5ingh.js/*-dark.conf | head -n 1)

# 3. Copy it to a FIXED name so Hyprland can always find it
cp "$LATEST_CONF" ~/.cache/WallRizz/colors-rizz.conf

# 4. Tell Hyprland to refresh
hyprctl reload
