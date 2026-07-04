import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Wayland
import Quickshell.Hyprland

// ============================================================
// Quickshell configuration entry point
//
// Hyprland keybinds:
//   bind = $mainMod CTRL, T, global, quickshell:toggle-theme
// ============================================================

ShellRoot {
    // Theme toggle via Hyprland global shortcut
    GlobalShortcut {
        name: "toggle-theme"
        description: "Toggle Quickshell theme (matugen / black / white)"

        onPressed: {
            var modes = ["matugen", "black", "white"]
            var idx = modes.indexOf(Theme.mode)
            Theme.setMode(modes[(idx + 1) % modes.length])
        }
    }

    // Top bar (replaces Waybar)
    Bar {}

    // Application launcher (replaces Rofi)
    AppLauncher {}
}