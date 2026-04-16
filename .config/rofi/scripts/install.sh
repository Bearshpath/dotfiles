#!/bin/bash

# Array for consistent Rofi styling
ROFI_OPTS=(-dmenu -i -config "$HOME/.config/rofi/config.rasi")

# 1. Get package name
PKG=$(rofi "${ROFI_OPTS[@]}" -p "Install Package:")
[ -z "$PKG" ] && exit 0

# 2. Choice of Manager
MANAGER=$(echo -e "pacman\nyay" | rofi "${ROFI_OPTS[@]}" -p "Manager:")
[ -z "$MANAGER" ] && exit 0

# 3. PREVIEW STEP
if [ "$MANAGER" == "pacman" ]; then
    INFO=$(pacman -Si "$PKG" 2>/dev/null | grep -E "Name|Version|Installed Size|Description")
    CHECK_INSTALLED=$(pacman -Qi "$PKG" &>/dev/null && echo "⚠️ WARNING: This package is already installed!")
else
    INFO=$(yay -Si "$PKG" 2>/dev/null | grep -E "Name|Version|Size|Description")
    CHECK_INSTALLED=$(yay -Qi "$PKG" &>/dev/null && echo "⚠️ WARNING: This package is already installed!")
fi

if [ -z "$INFO" ]; then
    rofi -e "Error: Package '$PKG' not found."
    exit 1
fi

# 4. CONFIRMATION
CONFIRM=$(echo -e "Yes\nNo" | rofi "${ROFI_OPTS[@]}" -p "Proceed?" -mesg "$CHECK_INSTALLED\n\n$INFO")
[ "$CONFIRM" != "Yes" ] && exit 0

# 5. EXECUTION
if [ "$MANAGER" == "pacman" ]; then
    # pkexec pops the GUI password prompt
    OUTPUT=$(pkexec pacman -S "$PKG" --noconfirm 2>&1)
    STATUS=$?
else
    OUTPUT=$(yay -S "$PKG" --noconfirm 2>&1)
    STATUS=$?
fi

# 6. FINAL RESULT (SCROLLABLE)
if [ $STATUS -eq 0 ]; then
    TITLE="✅ INSTALLATION SUCCESSFUL"
else
    TITLE="❌ INSTALLATION FAILED (Code: $STATUS)"
fi

# We build the message in a variable to handle newlines correctly
RESULT=$(printf "$TITLE\n\n$OUTPUT")

# IMPORTANT: Put the -config BEFORE the -e message
rofi -config "$HOME/.config/rofi/config.rasi" -e "$RESULT"
