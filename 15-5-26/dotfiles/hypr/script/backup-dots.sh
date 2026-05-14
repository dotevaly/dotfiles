#!/bin/bash

# Define directories
BACKUP_ROOT="$HOME/Nextcloud/configs"
CURRENT_DIR="$BACKUP_ROOT/current"
DATE_DIR=$(date +"%d-%-y")
TARGET_DIR="$BACKUP_ROOT/$DATE_DIR/dotfiles"

LOCAL_DATE_FILE="$HOME/.config/hypr/date.txt"
CURRENT_DATE_FILE="$CURRENT_DIR/date.txt"

# 1. Update/Create the local date.txt with the new two-line format
# This ensures LOCAL_TS will always be an integer moving forward
echo "$(date +%s)" > "$LOCAL_DATE_FILE"
echo "$(date +'%d-%m-%Y %H:%M')" >> "$LOCAL_DATE_FILE"

# 2. Logic to decide if we update 'current'
SHOULD_UPDATE_CURRENT=false

if [ ! -f "$CURRENT_DATE_FILE" ]; then
    SHOULD_UPDATE_CURRENT=true
else
    LOCAL_TS=$(head -n 1 "$LOCAL_DATE_FILE")
    CURRENT_TS=$(head -n 1 "$CURRENT_DATE_FILE")

    # Check if CURRENT_TS is actually a number (to avoid the "integer expected" error)
    if [[ "$CURRENT_TS" =~ ^[0-9]+$ ]]; then
        if [ "$LOCAL_TS" -ge "$CURRENT_TS" ]; then
            SHOULD_UPDATE_CURRENT=true
        fi
    else
        # If the file exists but isn't a number (old format), overwrite it
        echo "Old date format detected in 'current'. Upgrading to timestamp format."
        SHOULD_UPDATE_CURRENT=true
    fi
fi

# 3. Execution
CONFIGS=("hypr" "rofi" "mako" "waybar" "kitty")

echo "Starting backup to $TARGET_DIR..."
mkdir -p "$TARGET_DIR"

if [ "$SHOULD_UPDATE_CURRENT" = true ]; then
    echo "Updating rolling config in $CURRENT_DIR..."
    mkdir -p "$CURRENT_DIR"
    cp "$LOCAL_DATE_FILE" "$CURRENT_DIR/date.txt"
fi

for folder in "${CONFIGS[@]}"; do
    if [ -d "$HOME/.config/$folder" ]; then
        # Always backup to the dated folder
        cp -r "$HOME/.config/$folder" "$TARGET_DIR/"
        
        # Only update current if local is newer/same
        if [ "$SHOULD_UPDATE_CURRENT" = true ]; then
            cp -r "$HOME/.config/$folder" "$CURRENT_DIR/"
        fi
        echo "✓ Backed up $folder"
    else
        echo "✗ Warning: ~/.config/$folder not found, skipping."
    fi
done

notify-send "Backup Complete" "Config saved to $DATE_DIR" -i drive-harddisk
