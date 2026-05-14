#!/bin/bash

# --- Configuration ---
BACKUP_ROOT="$HOME/Nextcloud/configs"
CURRENT_DIR="$BACKUP_ROOT/current"
CURRENT_DATE_FILE="$CURRENT_DIR/date.txt"
LOCAL_DATE_FILE="$HOME/.config/hypr/date.txt"
MONITOR_CONF="$HOME/.config/hypr/monitors.conf"
CONFIGS=("hypr" "rofi" "mako" "waybar" "kitty")

# 1. Pre-check: Does the backup even exist?
if [ ! -f "$CURRENT_DATE_FILE" ]; then
    notify-send "Restore Failed" "No backup found in Nextcloud/configs/current" -u critical
    exit 1
fi

# 2. Comparison Logic
CLOUD_TS=$(head -n 1 "$CURRENT_DATE_FILE")
LOCAL_TS=0

if [ -f "$LOCAL_DATE_FILE" ]; then
    LOCAL_TS=$(head -n 1 "$LOCAL_DATE_FILE")
    if [[ ! "$LOCAL_TS" =~ ^[0-9]+$ ]]; then
        LOCAL_TS=0
    fi
fi

PERMIT_RESTORE=false

if [ "$CLOUD_TS" -ge "$LOCAL_TS" ]; then
    PERMIT_RESTORE=true
else
    HUMAN_CLOUD=$(sed -n '2p' "$CURRENT_DATE_FILE")
    HUMAN_LOCAL=$(sed -n '2p' "$LOCAL_DATE_FILE")
    [ -z "$HUMAN_LOCAL" ] && HUMAN_LOCAL=$(cat "$LOCAL_DATE_FILE")

    if zenity --question --title="Older Backup Warning" \
        --text="The config in Nextcloud is <b>older</b> than your local config.\n\n<b>Cloud:</b> $HUMAN_CLOUD\n<b>Local:</b> $HUMAN_LOCAL\n\nDo you want to overwrite your local setup anyway?" \
        --width=350; then
        PERMIT_RESTORE=true
    else
        echo "Restore aborted by user."
        exit 0
    fi
fi

# 3. Execution
if [ "$PERMIT_RESTORE" = true ]; then
    echo "Starting restore..."

    # PRE-RESTORE: Preserve existing monitor config if it exists
    if [ -f "$MONITOR_CONF" ]; then
        echo "Preserving existing monitor configuration..."
        cp "$MONITOR_CONF" /tmp/monitors.conf.bak
        HAS_MONITOR_BAK=true
    else
        HAS_MONITOR_BAK=false
    fi

    for folder in "${CONFIGS[@]}"; do
        if [ -d "$CURRENT_DIR/$folder" ]; then
            # Remove local version and replace using cp
            rm -rf "$HOME/.config/$folder"
            cp -r "$CURRENT_DIR/$folder" "$HOME/.config/"
            echo "✓ Restored $folder"
        fi
    done

    # POST-RESTORE: Hardware-specific monitor logic
    if [ "$HAS_MONITOR_BAK" = true ]; then
        echo "Restoring preserved monitor settings..."
        mv /tmp/monitors.conf.bak "$MONITOR_CONF"
    else
        echo "No monitor config found. Creating default placeholder..."
        cat <<EOF > "$MONITOR_CONF"
# Default Monitor Configuration (New Setup)
monitor=,preferred,auto,1
EOF
    fi

    # 4. Permission Management
    # Automatically chmod +x all scripts within the restored directories
    echo "Fixing script permissions..."
    find "$HOME/.config/hypr/script" -type f -name "*.sh" -exec chmod +x {} +
    find "$HOME/.config/waybar/scripts" -type f -name "*.sh" -exec chmod +x {} +

    # 5. Create the 'Restored' date.txt (Human Readable Only)
    RESTORE_TIME=$(date +'%d-%m-%Y %H:%M')
    ORIGINAL_TIME=$(sed -n '2p' "$CURRENT_DATE_FILE")
    
    echo "Last restored on: $RESTORE_TIME" > "$LOCAL_DATE_FILE"
    echo "Source backup date: $ORIGINAL_TIME" >> "$LOCAL_DATE_FILE"

    # 6. The "Anti-Fumble" Sequence
    echo "Refreshing desktop environment..."
    
    # Reload Hyprland
    hyprctl reload >/dev/null 2>&1

    # Restart Waybar
    if pgrep -x "waybar" > /dev/null; then
        pkill -x "waybar"
        sleep 0.5
        waybar & disown
    fi

    # Reload Mako
    if pgrep -x "mako" > /dev/null; then
        makoctl reload >/dev/null 2>&1
    fi

    # Refresh Kitty
    pkill -USR1 kitty

    notify-send "Restore Complete" "Configs synced, monitors preserved, and services refreshed." -i drive-harddisk
    echo "Restore finished successfully."
fi
