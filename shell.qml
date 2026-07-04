import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Wayland

// ============================================================
// Quickshell configuration entry point
//
// Theme follows system dark/light mode via dconf.
//   dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
//   dconf write /org/gnome/desktop/interface/color-scheme "'default'"
// ============================================================

ShellRoot {
    // Top bar (replaces Waybar)
    Bar {}

    // Application launcher (replaces Rofi)
    AppLauncher {}
}