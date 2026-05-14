# dotfiles

Hyprland-based dotfiles with Nextcloud sync for backup/restore workflow.

## Dependencies

| Package | Purpose |
|---------|---------|
| [hyprland](https://hyprland.org/) | Wayland compositor |
| [waybar](https://github.com/Alexays/Waybar) | Status bar |
| [rofi](https://github.com/davatorium/rofi) | Application launcher |
| [kitty](https://sw.kovidgoyal.net/kitty/) | Terminal emulator |
| [mako](https://github.com/emersion/mako) | Notification daemon |
| [pywal](https://github.com/dylanaraps/pywal) | Dynamic color theming |
| [hyprlock](https://github.com/hyprwm/hyprlock) | Screen locker |
| [cliphist](https://github.com/semanticart/cliphist) | Clipboard manager |
| [zenity](https://help.gnome.org/users/zenity/) | GUI dialogs |

## Installation

Prerequisites: Install all dependencies above (via pacman, yay, etc.).

```bash
# Clone repository
git clone https://github.com/doteva/dotfiles.git
cd dotfiles

# Copy configs to ~/.config/
cp -r hypr ~/.config/
cp -r kitty ~/.config/
cp -r mako ~/.config/
cp -r rofi ~/.config/
cp -r waybar ~/.config/

# Make scripts executable
chmod +x ~/.config/hypr/script/*.sh
chmod +x ~/.config/waybar/scripts/*.sh

# Set up wallpaper directory (for Wall.sh script)
mkdir -p ~/Nextcloud/Wallpapers

# Restart Hyprland or log out/in
```

## Config Breakdown

| Directory | Description |
|-----------|-------------|
| `hypr/` | Main Hyprland config, scripts, monitors.conf |
| `kitty/` | Terminal configuration |
| `rofi/` | App launcher styling |
| `mako/` | Notification daemon config |
| `waybar/` | Status bar with GPU/CPU monitoring scripts |

## Keybindings

| Binding | Action |
|---------|--------|
| `SUPER + W` | Cycle wallpaper forward |
| `SUPER + SHIFT + W` | Cycle wallpaper backward |
| `SUPER + L` | Lock screen |
| `SUPER + ALT + B` | Backup configs to Nextcloud |
| `SUPER + ALT + SHIFT + B` | Restore configs from Nextcloud |

## Backup/Restore (Nextcloud)

These scripts use Nextcloud as the sync/backup target. They expect:
- Backup path: `~/Nextcloud/configs/`
- Wallpapers: `~/Nextcloud/Wallpapers/`

### Backup (`backup-dots.sh`)

Backs up to two locations:
1. **Dated folder** (`~/Nextcloud/configs/DD-YY/dotfiles/`) - always created
2. **Rolling folder** (`~/Nextcloud/configs/current/`) - only if local is newer

Decision logic:
- Compares local `~/.config/hypr/date.txt` timestamp vs cloud `current/date.txt`
- Updates rolling backup only if local is same or newer
- Sends notification on completion

### Restore (`restore-dots.sh`)

1. **Pre-check**: Verifies backup exists in `current/`
2. **Comparison**: Checks if cloud backup is same or newer than local
   - If cloud is older, shows zenity dialog to confirm overwrite
3. **Execution**:
   - Preserves local `monitors.conf` (hardware-specific)
   - Copies configs from `current/` to `~/.config/`
   - Restores preserved monitor config after copy
   - Fixes script permissions (`chmod +x`)
4. **Refresh**: Reloads hypr, waybar, mako, and kitty
5. **Logging**: Creates local `date.txt` recording restore time and source backup date

### Monitor Preservation

`restore-dots.sh` protects `monitors.conf` because it contains hardware-specific display configurations. If a local copy exists, it's backed to `/tmp/monitors.conf.bak` before restore and restored afterward. On fresh setups with no existing monitor config, a default placeholder is created.

## Color System

Pywal generates color schemes from wallpapers:
- Colors stored in `~/.cache/wal/`
- Imported via `~/.cache/wal/colors-hyprland.conf` (sourced by hyprland.conf)
- Scripts: `Wall.sh` (cycles wallpapers + updates pywal), `update-mako.sh` (updates mako colors)

## Directory Structure

```
~/.config/
├── hypr/
│   ├── hyprland.conf
│   ├── hyprpaper.conf
│   ├── hyprlock.conf
│   ├── monitors.conf       # Hardware-specific, preserved on restore
│   ├── date.txt            # Timestamps for backup comparison
│   └── script/
│       ├── backup-dots.sh
│       ├── restore-dots.sh
│       ├── Wall.sh
│       └── update-mako.sh
├── waybar/
│   ├── config.jsonc
│   ├── style.css
│   └── scripts/
│       └── gpu_usage.sh
├── kitty/kitty.conf
├── rofi/config.rasi
└── mako/config
```