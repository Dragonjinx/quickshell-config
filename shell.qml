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
// Hyprland keybind (add to your keybinding config):
//   bind = $mainMod, SUPER_L, global, quickshell:toggle-launcher
//
// Theme follows system dark/light mode via dconf.
//   dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
//   dconf write /org/gnome/desktop/interface/color-scheme "'default'"
// ============================================================

ShellRoot {
    // Toggle app launcher via Hyprland global shortcut
    GlobalShortcut {
        name: "toggle-launcher"
        description: "Toggle the application launcher"
        onPressed: appLauncher.toggle()
    }

    // Top bar (replaces Waybar)
    Bar {}

    // Application launcher (replaces Rofi)
    AppLauncher { id: appLauncher }
}