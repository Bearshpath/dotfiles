#!/bin/bash

# Get a list of all active special workspaces and extract their names
# hyprctl monitors -j | jq -r '.[].specialWorkspace.name' outputs names like "special:someName"
# The sed command removes the "special:" prefix
ACTIVE_SPECIALS=$(hyprctl monitors -j | jq -r '.[].specialWorkspace.name' | sed 's/special://' | grep -v '^null$' | sort | uniq)

# Loop through each unique active special workspace name and toggle it to hide it
for special_name in $ACTIVE_SPECIALS; do
  if [[ -n "$special_name" ]]; then
    hyprctl dispatch togglespecialworkspace "$special_name"
  fi
done
