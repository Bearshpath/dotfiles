#!/bin/bash

# 1. Use 'fd' to quickly list all files/folders in your Home directory.
# 2. Pipe the list into Rofi. The -theme-str flags make the window small and centered like PowerToys.
# 3. Save the user's selection as $SELECTED.
SELECTED=$(fd --hidden --exclude .git . ~/ | rofi -dmenu -i -p "Search Files: " \
    -theme-str 'window {width: 40%; border-radius: 8px;} listview {lines: 8;}')

# If the user selected something (didn't press escape), open it.
if [ -n "$SELECTED" ]; then
    # xdg-open automatically respects your default applications (and Thunar)
    xdg-open "$SELECTED"
fi

