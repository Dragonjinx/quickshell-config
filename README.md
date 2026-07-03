# Quickshell Config — Waybar + Rofi Replacement

A Quickshell-based desktop shell that replaces **Waybar** and **Rofi** with a single QML-powered UI on Hyprland (and other Wayland compositors).

## What It Does

| Feature | Status | Notes |
|---------|--------|-------|
| **Top Bar** (replaces Waybar) | ✅ | Multi-monitor, workspaces, window title, clock, volume, network, battery, systray |
| **App Launcher** (replaces Rofi) | ✅ | Desktop entries, search filtering, keyboard navigation |
| **Hardware monitoring** (CPU/RAM/Disk) | ⬜ | Planned — can use `Process` to call `btop` or `htop` data |
| **Bluetooth status** | ⬜ | Planned — `Quickshell.Bluetooth` API available |
| **Notification center** | ⬜ | Planned — `Quickshell.Services.Notifications` API available |
| **Power menu** (wlogout replacement) | ⬜ | Planned — see `wlogout` example from quickshell-examples |

## Structure

```
quickshell-config/
├── shell.qml                   # Entry point — activates services + loads UI
├── bar/
│   ├── Bar.qml                 # Top bar (PanelWindow per monitor)
│   ├── Workspaces.qml          # Hyprland workspace buttons
│   ├── WindowTitle.qml         # Active window title
│   ├── ClockWidget.qml         # Clock using SystemClock
│   ├── VolumeWidget.qml        # Volume (Pipewire) with mute toggle
│   ├── NetworkWidget.qml       # Network status (NM backend)
│   ├── BatteryWidget.qml       # Battery (UPower) with percentage
│   ├── TrayWidget.qml          # System tray (StatusNotifierItem)
│   └── LauncherButton.qml      # "Apps" button to open launcher
├── launcher/
│   ├── AppLauncher.qml         # App launcher (FloatingWindow, replaces Rofi)
│   └── AppEntry.qml            # Single app entry in the list
├── singletons/
│   ├── TimeSingleton.qml       # Clock time singleton
│   ├── VolumeSingleton.qml     # Volume state singleton
│   └── BatterySingleton.qml    # Battery state singleton
├── config/
│   └── Theme.qml               # Color palette (based on your Matugen colors)
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
- Click the **Apps** button or press **Super+Space** to open the launcher
- Type to filter applications, use arrow keys to navigate, Enter to launch
- Click volume to toggle mute
- Click network to open `nmtui`

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