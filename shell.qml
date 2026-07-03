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
// ============================================================
// Replaces Waybar + Rofi with a single QML-based shell.
//
// Structure:
//   shell.qml          → this file (entry point)
//   bar/Bar.qml        → top bar (PanelWindow per monitor)
//   launcher/AppLauncher.qml → app launcher (replaces rofi)
//   singletons/        → shared state (time, volume, battery)
//   config/Theme.qml   → color palette
// ============================================================

ShellRoot {
    id: root

    // ----------------------------------------------------------
    // Enable built-in services
    // ----------------------------------------------------------

    // Pipewire for audio control
    Pipewire {}

    // UPower for battery status
    UPower {}

    // NetworkManager integration
    Networking {
        backend: NetworkBackendType.NetworkManager
    }

    // Bluetooth
    Bluetooth {}

    // System tray (StatusNotifierItem protocol)
    SystemTray {}

    // Idle inhibitor for Wayland
    IdleInhibitor {}

    // ----------------------------------------------------------
    // UI Components
    // ----------------------------------------------------------

    // Top bar (replaces Waybar)
    Bar {}

    // Application launcher (replaces Rofi)
    AppLauncher {}
}