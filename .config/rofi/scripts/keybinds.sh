#!/bin/bash

CONF="$HOME/.config/hypr/hyprland.conf"

# 1. Get the lines
# 2. Strip comments
# 3. Use AWK to format into clean columns: [KEYS] -> [ACTION]
BINDS=$(grep -E '^bind[a-z]*\s*=' "$CONF" | sed 's/#.*$//' | awk -F, '{
    # Clean up the fields (remove leading/trailing whitespace)
    gsub(/^[ \t]+|[ \t]+$/, "", $1); 
    gsub(/^[ \t]+|[ \t]+$/, "", $2);
    
    # Strip the "bind =" part from the first field
    sub(/^bind[a-z]*\s*=\s*/, "", $1);
    
    # Replace $mainMod with SUPER for easier searching
    gsub(/\$mainMod/, "SUPER", $1);
    
    # Reconstruct the action (everything after the second comma)
    action = ""; 
    for(i=3; i<=NF; i++) {
        action = action $i (i==NF ? "" : ", ");
    }
    gsub(/^[ \t]+|[ \t]+$/, "", action);

    # Format output: Keys on left (padded to 25 chars), Arrow, Action
    if ($1 != "" && $2 != "") {
        printf "%-25s ->   %s\n", $1 " + " $2, action
    }
}')

# Run Rofi with a fixed-width font for perfect alignment
echo "$BINDS" | rofi -dmenu -i -p "Check Keys:" \
    -config ~/.config/rofi/config.rasi \
    -theme-str 'listview { lines: 15; } window { width: 800px; }'
