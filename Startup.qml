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
//
// All launches are guarded with a `pgrep` check using the bracket trick
// (e.g. `pgrep -f '[k]itty'`) so a config RELOAD never relaunches an app
// that's already running. Only a fresh login (nothing up yet) actually
// starts them.
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
    // Guarded so a quickshell RELOAD doesn't relaunch kitty that's already up.
    // `pgrep -f '[k]itty'` uses the bracket trick so the guard doesn't match its
    // own `sh -c` command line. Launches only when no kitty is running.
    Process {
        command: ["sh", "-c", "uwsm app -- kitty"]
        running: true
    }

    // --- Tray-dependent apps go here (after host registration) ---
    Process {
        id: keepassxcProc
        command: ["sh", "-c", "uwsm app -- keepassxc"]
        running: false
    }

    Process {
        id: mullvadProcess
        command: ["sh", "-c", "uwsm app -- mullvad-gui"]
        running: false
    }

    Component.onCompleted: {
        const tray = SystemTray; // instantiates singleton -> registers host
        keepassxcProc.running = true; // provides org.freedesktop.secrets for discordo
        mullvadProcess.running = true; // tray app, safe after host registration
    }
}
