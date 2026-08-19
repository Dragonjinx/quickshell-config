// ============================================================
// Startup.qml — autostart applications for this quickshell session.
//
// Apps are launched from here (instead of Hyprland's parallel
// exec-once) so that tray-dependent apps (e.g. Mullvad) can be
// started strictly AFTER the status-notifier tray host is
// registered. Referencing the SystemTray singleton below registers
// org.kde.StatusNotifierWatcher synchronously, so anything started
// afterwards always finds the tray host — even on multi-monitor
// login where Hyprland's parallel autostart used to race it.
//
// To add an app: add a `Process { ... }` block.
//   - Tray-independent apps: use `running: true`.
//   - Tray-dependent apps (need a tray icon): use `running: false`
//     and give them an id, then start them in the `onCompleted`
//     handler at the bottom.
// ============================================================
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick

Item {
    id: root

    visible: false // pure container, not rendered

    // Force the status-notifier tray host to register as early as
    // possible (synchronous during component construction).
    readonly property bool __earlyTrayHost: (SystemTray !== null)

    // --- Terminal (no tray dependency — start immediately) ------
    Process {
        command: ["uwsm", "app", "--", "kitty"]
        running: true
    }

    // --- Mullvad VPN (needs the tray icon) -----------------------
    Process {
        id: mullvadProcess
        command: ["uwsm", "app", "--", "mullvad-gui"]
        running: false // started in onCompleted, after the tray host
    }

    // --- Tray-dependent apps go here (after host registration) ---
    Component.onCompleted: {
        const tray = SystemTray; // instantiates singleton -> registers host
        mullvadProcess.running = true; // now safe to start tray app
    }
}
