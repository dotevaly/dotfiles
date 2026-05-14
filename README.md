# dotfiles

Hyprland-based dotfiles with Nextcloud sync for backup/restore workflow.

## Dependencies

| Package | Purpose |
|---------|---------|
| [hyprland](https://hyprland.org/) | Wayland compositor |
| [waybar](https://github.com/Alexays/Waybar) | Status bar |
| [rofi](https://github.com/davatorium/rofi) | Application launcher |
| [kitty](https://sw.kovidgoyal.net/kitty/) | Terminal emulator |
| [dolphin](https://apps.kde.org/dolphin/) | File manager |
| [mako](https://github.com/emersion/mako) | Notification daemon |
| [pywal](https://github.com/dylanaraps/pywal) | Dynamic color theming |
| [hyprlock](https://github.com/hyprwm/hyprlock) | Screen locker |
| [hyprpaper](https://github.com/hyprwm/hyprpaper) | Wallpaper daemon |
| [hyprshot](https://github.com/Gustash/hyprshot) | Screenshots |
| [cliphist](https://github.com/semanticart/cliphist) | Clipboard manager |
| [wl-clipboard](https://github.com/bugaevc/wl-clipboard) | Clipboard CLI (`wl-paste`, `wl-copy`) |
| [nm-applet](https://wiki.gnome.org/Projects/NetworkManager) | NetworkManager tray icon |
| [networkmanager_dmenu](https://github.com/firecat53/networkmanager-dmenu) | Network menu via rofi |
| [rofi-bluetooth](https://github.com/nickclyde/rofi-bluetooth) | Bluetooth menu via rofi |
| [hyprpolkitagent](https://github.com/hyprwm/hyprpolkitagent) | PolKit authentication agent |
| [xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland) | Desktop portal (file pickers, screen capture) |
| [nextcloud](https://nextcloud.com/) | Nextcloud sync client |
| [bitwarden-desktop](https://bitwarden.com/) | Password manager |
| [go-hass-agent](https://github.com/home-assistant/go-hass-agent) | Home Assistant integration |
| [wireplumber](https://github.com/PipeWire/wireplumber) | Audio management (`wpctl`) |
| [pavucontrol](https://freedesktop.org/software/pulseaudio/pavucontrol/) | PulseAudio GUI (waybar on-click) |
| [brightnessctl](https://github.com/Hummer12007/brightnessctl) | Backlight control |
| [playerctl](https://github.com/altdesktop/playerctl) | Media player controls |
| [zenity](https://help.gnome.org/users/zenity/) | GUI dialogs |
| [dbus-update-activation-environment](https://github.com/flatpak/xdg-dbus-proxy) | DBus environment setup |
| jetbrains-mono-nerd-font | Monospace font (mako, rofi) |
| oranchelo-icon-theme | Icon theme (rofi) |

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
| `SUPER + Q` | Open terminal (kitty) |
| `SUPER + C` | Close window |
| `SUPER + E` | File manager (dolphin) |
| `SUPER + R` | App launcher (rofi) |
| `SUPER + V` | Toggle floating |
| `SUPER + F` | Fullscreen |
| `SUPER + L` | Lock screen |
| `SUPER + S` | Screenshot region |
| `SUPER + SHIFT + S` | Screenshot window |
| `SUPER + SHIFT + P` | Screenshot monitor |
| `SUPER + B` | NetworkManager menu (rofi) |
| `SUPER + SHIFT + B` | Bluetooth menu (rofi) |
| `SUPER + SHIFT + V` | Clipboard history (cliphist + rofi) |
| `SUPER + W` | Cycle wallpaper forward |
| `SUPER + SHIFT + W` | Cycle wallpaper backward |
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
## Screenshots
<img width="2560" height="1440" alt="pasted file" src="https://github.com/user-attachments/assets/b0f43c0e-2703-4b61-950e-99ce47491834" />
<img width="2560" height="1440" alt="2" src="https://github.com/user-attachments/assets/f0eb31a3-ff10-484c-89ae-645c32f072f3" />
<img width="2560" height="1440" alt="rofi and notifs" src="https://github.com/user-attachments/assets/f4385f76-a2e7-41ee-a036-d7d022b3bcf4" />
