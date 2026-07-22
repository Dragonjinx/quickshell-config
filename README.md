# Quickshell Config — Waybar + Rofi Replacement

A Quickshell-based desktop shell that replaces **Waybar** and **Rofi** with a single QML-powered UI on Hyprland (and other Wayland compositors).

## What It Does

| Feature | Status | Notes |
|---------|--------|-------|
| **Top Bar** (replaces Waybar) | ✅ | Multi-monitor, workspaces, window title, clock, volume, network, bluetooth, battery, systray, resource monitor |
| **App Launcher** (replaces Rofi) | ✅ | Desktop entries, search filtering, keyboard navigation |
| **Hardware monitoring** (CPU/RAM/Disk) | ✅ | Via `/proc` polling, click opens btop |
| **Bluetooth status** | ✅ | Device list popup, click opens bluetoothctl |
| **Network status** | ✅ | MDI wifi/ethernet icons with signal %, popup shows active connections |
| **Power menu** (wlogout replacement) | ✅ | In-bar popup: Lock, Logout, Suspend, Hibernate, Shutdown, Reboot |
| **Notification center** | ⬜ | Planned — `Quickshell.Services.Notifications` API available |

## Structure

```
quickshell-config/
├── shell.qml                   # Entry point — activates services + loads UI
├── Bar.qml                     # Top bar (PanelWindow per monitor)
├── Theme.qml                   # Color palette + font sizes (based on your Matugen colors)
├── Workspaces.qml              # Hyprland workspace buttons
├── WindowTitle.qml             # Active window title (centered)
├── ClockWidget.qml             # Clock (24h) + date toggle + calendar popup
├── VolumeSingleton.qml         # Volume + mic state singleton
├── VolumeWidget.qml            # Volume icon + percentage in bar
├── NetworkWidget.qml           # Network status (NM backend, nmcli monitor)
├── BluetoothWidget.qml         # Bluetooth device list popup
├── BatterySingleton.qml        # Battery state singleton (UPower)
├── BatteryWidget.qml           # Battery icon + percentage in bar
├── ResourceWidget.qml          # CPU / RAM / Disk percentages
├── TrayWidget.qml              # System tray (StatusNotifierItem)
├── PowerMenuWidget.qml         # Power actions popup (Lock, Logout, etc.)
├── PowerAction.qml             # Single power action button component
├── AppLauncher.qml             # App launcher (FloatingWindow, replaces Rofi)
├── AppEntry.qml                # Single app entry in the list
├── CalendarPopup.qml           # Gregorian calendar hover popup
├── TimeSingleton.qml           # Clock time singleton
├── flake.nix                   # Nix flake for building/running
└── README.md                   # This file
```

## Installation

### NixOS (recommended)

Add to your flake inputs:

```nix
quickshell-config.url = "github:your-username/quickshell-config";
```

Then run with:

```bash
nix run .#shell
```

Or add to `environment.systemPackages` after building.

### Non-NixOS

1. Install Quickshell from your distro's packages (see [quickshell.org](https://quickshell.org/docs/v0.3.0/guide/install-setup))
2. Clone this repo to `~/.config/quickshell` (or use `--path`):

```bash
git clone https://github.com/your-username/quickshell-config ~/.config/quickshell
quickshell
```

## Usage

After starting Quickshell (via `exec-once` in Hyprland's config):

- The top bar appears on all monitors
- Press **Super+Space** or click the power icon to open the app launcher
- Type to filter applications, use arrow keys to navigate, Enter to launch
- Click volume to open wiremix; right-click to toggle mic
- Click power icon ⏻ to show power menu (Lock, Logout, Suspend, Hibernate, Shutdown, Reboot)
- Hover Bluetooth or Network icons for connection popups
- Click battery to toggle between percentage and time remaining

## Switching from Waybar + Rofi

1. **Stop Waybar**: remove/comment the `exec-once = ~/.config/waybar/launch.sh` line in `~/.config/hypr/conf/autostart.conf`
2. **Start Quickshell**: add `exec-once = quickshell` (or `exec-once = nix run .#shell` if using flakes)
3. **Update keybinds**: change the `$mainMod, SUPER_L` bind in `~/.config/hypr/conf/keybindings/default.conf` to toggle Quickshell's launcher instead of Rofi.
   → Instead of `pkill rofi || rofi -show drun`, you can use a Hyprland `GlobalShortcut` or keep the keybind as-is and have the launcher listen for it.
4. **Keep Rofi** for any modes you still need (like run, filebrowser, window switcher) or port them to Quickshell later.

## Configuration

Edit `config/Theme.qml` to change colors. The current palette is based on your Matugen-generated colors.

To add new modules:
- Create a `.qml` file in `bar/` (or `launcher/` etc.)
- Import and instantiate it in `Bar.qml` or `shell.qml`

## Development

```bash
# Enter dev shell with qmlls LSP support
nix develop

# Run with live-reload
quickshell -c /path/to/quickshell-config
```

Quickshell live-reloads on file save — just edit and see changes instantly.