#!/bin/bash

WALLPAPER_DIR="$HOME/Nextcloud/Wallpapers"
STATE_FILE="$HOME/.cache/current_wallpaper_index"
HYPR_CONF="$HOME/.config/hypr/hyprpaper.conf"

# 1. Get wallpapers
mapfile -t WALLS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)
TOTAL_WALLS=${#WALLS[@]}
[ "$TOTAL_WALLS" -eq 0 ] && exit 1

# 2. Check for the -r (reverse) flag
DIRECTION="next"
while getopts "r" opt; do
  case $opt in
    r) DIRECTION="prev" ;;
    *) echo "Usage: $0 [-r]"; exit 1 ;;
  esac
done

# 3. Track Index and Calculate Next/Prev
INDEX=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

if [ "$DIRECTION" == "prev" ]; then
    # Go back: (index - 1 + total) % total handles the 0 -> last wrap
    NEXT_INDEX=$(( (INDEX - 1 + TOTAL_WALLS) % TOTAL_WALLS ))
else
    # Go forward: (index + 1) % total handles the last -> 0 wrap
    NEXT_INDEX=$(( (INDEX + 1) % TOTAL_WALLS ))
fi

NEXT_WALL="${WALLS[$NEXT_INDEX]}"
echo "$NEXT_INDEX" > "$STATE_FILE"

# 3. Write the new block-style config
# Clear the file first
: > "$HYPR_CONF"

# Get all active monitor names
MONITORS=$(hyprctl monitors -j | jq -r '.[] | .name')

for MONITOR in $MONITORS; do
    cat <<EOF >> "$HYPR_CONF"
wallpaper {
    monitor = $MONITOR
    path = $NEXT_WALL
    fit_mode = cover
}
EOF
done

# 4. Run Pywal
wal -i "$NEXT_WALL" > /dev/null 2>&1

# 5. Execution Logic
# Note: IPC commands (preload/wallpaper) still use the old syntax 
# because hyprctl doesn't support block-style arguments yet.
if pgrep -x "hyprpaper" > /dev/null; then
    hyprctl hyprpaper preload "$NEXT_WALL"
    for MONITOR in $MONITORS; do
        hyprctl hyprpaper wallpaper "$MONITOR,$NEXT_WALL"
    done
    hyprctl hyprpaper unload unused
else
    # Start fresh
    rm -rf /tmp/hypr/*
    hyprpaper &
    disown
fi

# 6. Refresh Waybar
killall -USR2 waybar
~/.config/hypr/script/update-mako.sh 
