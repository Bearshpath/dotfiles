#!/bin/bash

MODE=$1 # Accepts: open, rename, delete, create
CURRENT_DIR=$HOME # Starts in home directory

while true; do
    # 1. Build the top menu options based on the shortcut you pressed
    OPTIONS=".. [Go Back]\n"

    if [ "$MODE" == "create" ]; then
        OPTIONS="> [Create File in THIS Folder]\n$OPTIONS"
    elif [ "$MODE" == "open" ]; then
        OPTIONS="> [Open THIS Folder in Thunar]\n$OPTIONS"
    elif [ "$MODE" == "rename" ]; then
        OPTIONS="> [Rename THIS Folder]\n$OPTIONS"
    elif [ "$MODE" == "delete" ]; then
        OPTIONS="> [Delete THIS Folder]\n$OPTIONS"
    fi

    # 2. Get files and folders. 
    # -1A shows hidden files (dotfiles)
    # -p adds a trailing slash to folders so you can tell them apart
    # --group-directories-first puts folders at the top
    FILES=$(ls -1A -p --group-directories-first "$CURRENT_DIR")
    OPTIONS="$OPTIONS$FILES"

    # 3. Open Rofi
    SELECTION=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "$MODE: " -mesg "Path: $CURRENT_DIR" \
        -theme-str 'window {width: 40%;} listview {lines: 12;}')

    # If you press Escape, exit the script
    if [ -z "$SELECTION" ]; then exit 0; fi

    # 4. Handle "Go Back"
    if [ "$SELECTION" == ".. [Go Back]" ]; then
        CURRENT_DIR=$(dirname "$CURRENT_DIR")
        continue
    fi

    # 5. Handle Folder Navigation 
    # If you click a folder, it always navigates INTO it. 
    # If you want to rename/delete a folder, you go inside it and click the "> [Action]" option at the top.
    if [[ "$SELECTION" == */ ]]; then
        CURRENT_DIR="$CURRENT_DIR/${SELECTION%/}"
        continue
    fi

    # 6. Figure out if we are applying the action to the current folder, or a file
    if [[ "$SELECTION" == \>* ]]; then
        TARGET="$CURRENT_DIR"
        TARGET_NAME=$(basename "$CURRENT_DIR")
        IS_DIR_ACTION=true
    else
        TARGET="$CURRENT_DIR/$SELECTION"
        TARGET_NAME="$SELECTION"
        IS_DIR_ACTION=false
    fi

    # 7. PERFORM THE ACTIONS
    if [ "$MODE" == "create" ] && [ "$IS_DIR_ACTION" = true ]; then
        NEW_FILE=$(rofi -dmenu -p "New File Name:" -theme-str 'window {width: 30%;} listview {lines: 0;}')
        if [ -n "$NEW_FILE" ]; then 
            touch "$CURRENT_DIR/$NEW_FILE" 
        fi
        continue # Reloads Rofi so you can see your newly created file

    elif [ "$MODE" == "open" ]; then
        xdg-open "$TARGET" # Opens using your default app / Thunar
        break 

    elif [ "$MODE" == "rename" ]; then
        NEW_NAME=$(rofi -dmenu -p "Rename $TARGET_NAME to:" -theme-str 'window {width: 30%;} listview {lines: 0;}')
        if [ -n "$NEW_NAME" ]; then
            mv "$TARGET" "$(dirname "$TARGET")/$NEW_NAME"
        fi
        if [ "$IS_DIR_ACTION" = true ]; then break; else continue; fi

    elif [ "$MODE" == "delete" ]; then
        # Confirmation prompt!
        CONFIRM=$(echo -e "No\nYes" | rofi -dmenu -p "DELETE '$TARGET_NAME'? [No/Yes]" -theme-str 'window {width: 25%; border-color: red;} listview {lines: 2;}')
        if [ "$CONFIRM" == "Yes" ]; then
            rm -rf "$TARGET"
            if [ "$IS_DIR_ACTION" = true ]; then break; else continue; fi
        else
            continue
        fi
    fi
done
