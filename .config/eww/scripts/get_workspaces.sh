#!/bin/bash

# Define a function to output the JSON
print_workspaces() {
    hyprctl workspaces -j | jq -c 'sort_by(.id) | map({id: .id, active: false}) | . + [{"id": "special:special", "active": false}]'
}

# Initial output
# We will let Eww handle the active state via a separate variable to keep it fast
echo "[1, 2, 3, 4, 5]"
