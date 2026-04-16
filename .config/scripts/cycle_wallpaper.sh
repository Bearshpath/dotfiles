#!/bin/bash

# Paths
DIR="$HOME/Desktop/wallpapers"
CACHE="/tmp/current_wallpaper_index"
HYPR_WAL="$HOME/.cache/wal/colors-hyprland.conf"

# 1. Get Images
FILES=($(ls "$DIR" | grep -E ".jpg|.png|.jpeg"))
COUNT=${#FILES[@]}
if [ ! -f "$CACHE" ]; then echo 0 > "$CACHE"; fi
INDEX=$(cat "$CACHE")
NEXT_INDEX=$(( (INDEX + 1) % COUNT ))
IMG_PATH="$DIR/${FILES[$NEXT_INDEX]}"

# 2. Apply wallpaper & Generate colors
# ... inside your script ...

# 22. Apply wallpaper & Generate colors
awww img "$IMG_PATH" --transition-type none
wal -i "$IMG_PATH" -n

# ADD THIS LINE RIGHT HERE:
cp "$IMG_PATH" /tmp/current_wallpaper.jpg

awww img "$IMG_PATH" --transition-type none
wal -i "$IMG_PATH" -n

# 3. Create a PERFECT file for Hyprland v0.53.3
# This loop generates all 16 colors so you never get a "not found" error
echo "# Pywal Colors for Hyprland" > "$HYPR_WAL"
mapfile -t colors < <(cat ~/.cache/wal/colors | sed 's/#//')

for i in "${!colors[@]}"; do
    echo "\$color$i = rgb(${colors[$i]})" >> "$HYPR_WAL"
done

# Add the background/foreground specifically
echo "\$background = rgb(${colors[0]})" >> "$HYPR_WAL"
echo "\$foreground = rgb(${colors[15]})" >> "$HYPR_WAL"

# 4. Save index and Force Hyprland/Waybar to see it
echo "$NEXT_INDEX" > "$CACHE"

# Tell Firefox (Pywalfox) to update colors automatically
/usr/bin/python -m pywalfox update

# Reload Hyprland and Waybar
hyprctl reload
killall -SIGUSR2 waybar
eww reload

# Update Firefox (Tell it the CSS files have changed)
if [ -d "$FF_PROFILE/chrome" ]; then
    touch "$FF_PROFILE/chrome/userChrome.css"
    touch "$FF_PROFILE/chrome/userContent.css"
fi
