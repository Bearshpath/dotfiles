#!/bin/bash

CONF="$HOME/.config/niri/config.kdl"

BINDS=$(grep -E '^\s*(Mod|XF86|Print|Ctrl|Alt|Super)[^{]+{[^}]+}' "$CONF" | awk -F'{' '{
    keys = $1;
    action = $2;
    
    # Clean up the KEYS side
    gsub(/^[ \t]+|[ \t]+$/, "", keys);
    gsub(/allow-[a-z-]+=[a-z]+/, "", keys);
    gsub(/cooldown-ms=[0-9]+/, "", keys);
    gsub(/hotkey-overlay-title="[^"]+"/, "", keys);
    gsub(/repeat=(true|false)/, "", keys);
    gsub(/Mod/, "SUPER", keys);
    gsub(/^[ \t]+|[ \t]+$/, "", keys);
    
    # Clean up the ACTION side
    gsub(/^[ \t]+|[ \t]+$/, "", action);
    gsub(/;[ \t]*}/, "", action);
    
    if (keys != "" && action != "") {
        printf "%-25s ->   %s\n", keys, action
    }
}')

echo "$BINDS" | rofi -dmenu -i -p "Niri Keys:" \
    -config ~/.config/rofi/config.rasi \
    -theme-str 'listview { lines: 15; } window { width: 800px; }'
