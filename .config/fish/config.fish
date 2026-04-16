if status is-interactive
# Commands to run in interactive sessions can go here
fastfetch
end

# Created by `pipx` on 2026-02-10 18:54:14
set PATH $PATH /home/sachin/.local/bin
set -U fish_user_paths $HOME/.local/bin $fish_user_paths

function play-minecraft
    set_color cyan; echo "➔ Starting Ultra-Minecraft Controller Setup..."

    # 1. Clean up "Ghost" Monitors (Handles HEADLESS, HEADER, etc.)
    set_color yellow; echo "➔ Sweeping for ghost monitors..."
    set ghosts (hyprctl monitors | grep -E "HEADLESS|HEADER" | awk '{print $2}')
    if test -n "$ghosts"
        for ghost in $ghosts
            hyprctl output remove $ghost
            echo "   [✓] Nuked ghost: $ghost"
        end
    else
        echo "   [✓] No ghost monitors found."
    end

    # 2. Advanced Device Detection (Supports Multiple Phones)
    set devices (adb devices | grep -v "List" | grep "device\$" | awk '{print $1}')
    set device_count (count $devices)

    if test $device_count -eq 0
        set_color red; echo "✘ ERROR: No phone detected! Check USB cable and 'USB Debugging'."
        set_color normal; return 1
    else if test $device_count -gt 1
        set_color magenta; echo "➔ Multiple phones found! Please choose one:"
        for i in (seq $device_count)
            echo "   $i) $devices[$i]"
        end
        read -p 'echo "Select number: "' choice
        set target_serial $devices[$choice]
    else
        set target_serial $devices[1]
    end

    set_color green; echo "   [✓] Using Device: $target_serial"

    # 3. Apply Window Rules
    echo "➔ Locking Hyprland Rules..."
    hyprctl keyword windowrulev2 "float,class:(scrcpy)"
    hyprctl keyword windowrulev2 "size 450 900,class:(scrcpy)"
    hyprctl keyword windowrulev2 "center,class:(scrcpy)"
    hyprctl keyword windowrulev2 "alwaysontop,class:(scrcpy)"

    # 4. Launch Game Bridge
    set_color blue; echo "🚀 BRIDGE ACTIVE. (If cable unplugs, script will auto-cleanup)"
    set_color normal

    # Launching scrcpy with the specific serial number
    # If the cable is pulled, scrcpy will exit, and the script continues to cleanup
    scrcpy \
        -s "$target_serial" \
        --window-title="Minecraft-Mobile" \
        --keyboard=uhid \
        --mouse=uhid \
        --stay-awake \
        --power-off-on-close \
        --window-height=900

    # 5. The "Sudden Unplug" / Exit Cleanup
    set_color yellow; echo "➔ Connection lost or closed. Cleaning up..."
    hyprctl reload
    set_color green; echo "➔ [✓] Cleanup Complete. System is clean."
    set_color normal

function play
    mpv --no-video "ytdl://ytsearch1:$argv"
end
end
