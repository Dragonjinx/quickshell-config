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

### Non-NixOS

1. Install Quickshell from your distro's packages (see [quickshell.org](https://quickshell.org/docs/v0.3.0/guide/install-setup))
2. Clone this repo to `~/.config/quickshell` (or use `--path`):

```bash
git clone https://github.com/Dragonjinx/quickshell-config.git ~/.config/quickshell
quickshell
```

## Usage

After starting Quickshell:

- The top bar appears on all monitors
- Press **Super+Space** or click the power icon to open the app launcher
- Type to filter applications, use arrow keys to navigate, Enter to launch
- Click volume to open wiremix; right-click to toggle mic
- Click power icon ⏻ to show power menu (Lock, Logout, Suspend, Hibernate, Shutdown, Reboot)
- Hover Bluetooth or Network icons for connection popups
- Click battery to toggle between percentage and time remaining
