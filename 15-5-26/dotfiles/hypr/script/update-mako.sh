#!/bin/bash

# Define paths
CONFIG_FILE="$HOME/.config/mako/config"
WAL_COLORS="$HOME/.cache/wal/colors-mako"

# 1. Ensure "sort=-time" (newest on top) exists in the config
if ! grep -q "sort=-time" "$CONFIG_FILE"; then
    # Add it to the [Global] section if it's missing
    sed -i '/\[Global\]/a sort=-time' "$CONFIG_FILE" || sed -i '1i sort=-time' "$CONFIG_FILE"
fi

# 2. Check if Pywal colors exist
if [ -f "$WAL_COLORS" ]; then
    # Extract colors from the pywal cache
    BG=$(grep 'background-color' "$WAL_COLORS" | cut -d'=' -f2)
    TXT=$(grep 'text-color' "$WAL_COLORS" | cut -d'=' -f2)
    BRD=$(grep 'border-color' "$WAL_COLORS" | cut -d'=' -f2)

    # 3. Update the config file with new colors
    # We use a temp file to avoid partial writes
    sed -i "s/^background-color=.*/background-color=${BG}/" "$CONFIG_FILE"
    sed -i "s/^text-color=.*/text-color=${TXT}/" "$CONFIG_FILE"
    sed -i "s/^border-color=.*/border-color=${BRD}/" "$CONFIG_FILE"
fi

# 4. Reload Mako to apply changes
makoctl reload
