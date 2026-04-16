#!/bin/bash

# 1. Get raw logical dimensions from slurp
GEOM=$(slurp -f "%w %h")
if [ -z "$GEOM" ]; then exit 0; fi # Exit if you press Escape

# Extract width and height
W=$(echo $GEOM | awk '{print $1}')
H=$(echo $GEOM | awk '{print $2}')

# 2. Get the exact scale factor of your currently focused monitor from Hyprland
SCALE=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .scale')

# 3. Multiply logical pixels by your scale factor and round it
TRUE_W=$(echo "$W * $SCALE" | bc | awk '{print int($1+0.5)}')
TRUE_H=$(echo "$H * $SCALE" | bc | awk '{print int($1+0.5)}')

# 4. Copy and Notify
DIMENSIONS="${TRUE_W}x${TRUE_H}"
wl-copy "$DIMENSIONS"
notify-send "Measured (Native Pixels)" "$DIMENSIONS (Copied to clipboard)"

