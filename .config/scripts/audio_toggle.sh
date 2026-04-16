#its a script to toggle between
#laptop audio to loudness and autogain
#!/bin/bash

# File to track current state
STATE_FILE="/tmp/audio_mode"

if [ -f "$STATE_FILE" ]; then
    # Switch to Standard
    easyeffects -l "Laptop"
    rm "$STATE_FILE"
    notify-send -r 555 -t 2000 -u low "Audio Mode" "💻 Standard (Laptop)"
else
    # Switch to Boosted
    easyeffects -l "Loudness+Autogain"
    touch "$STATE_FILE"
    notify-send -r 555 -t 2000 -u normal "Audio Mode" "🔊 Boosted (Loudness)"
fi
