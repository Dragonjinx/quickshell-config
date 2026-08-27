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
// One-shot gate:
//   On the first load a marker file is created and the apps below are
//   launched. If that marker already exists (e.g. on a quickshell reload
//   within the same session), the apps are NOT re-launched, avoiding
//   duplicate kitty / keepassxc / mullvad instances.
//
//   The marker lives in $XDG_RUNTIME_DIR (tmpfs at /run/user/<uid>), NOT
//   /tmp. /tmp on this machine is disk-backed btrfs and would persist
//   across logins/reboots, which would suppress autostart forever. The
//   runtime dir is tmpfs -> cleared every reboot and per-session, so a
//   fresh login autostarts normally while reloads within a session skip.
//
// To add an app: add a `Quickshell.execDetached([...])` call inside
// `launchApps()` below. execDetached starts the app fully detached, so
// quickshell reloads never kill it.
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

    // --- Launch every listed app (native detach, one-shot) -------
    // Uses Quickshell.execDetached (same helper the app launcher uses) so
    // each app runs fully detached: it is NOT a child of a quickshell
    // Process object, so a quickshell reload never kills these apps.
    function launchApps() {
        Quickshell.execDetached(["uwsm-app", "--", "kitty"])
        Quickshell.execDetached(["uwsm-app", "--", "keepassxc"])
        Quickshell.execDetached(["uwsm-app", "--", "mullvad-gui"])
    }

    // --- Startup gate: checks whether the marker file exists ----
    Process {
        id: checkMarker
        command: ["sh", "-c", 'test -e "$XDG_RUNTIME_DIR/quickshell-startup"']
        running: false
        onExited: function(code, status) {
            if (code === 0) {
                // marker exists -> already started once, skip.
                return
            }
            // first run -> create the marker, then launch apps
            createMarker.running = true
            root.launchApps()
        }
    }

    // --- Writes the marker file (only on first run) -------------
    Process {
        id: createMarker
        command: ["sh", "-c", 'touch "$XDG_RUNTIME_DIR/quickshell-startup"']
        running: false
    }

    Component.onCompleted: {
        const tray = SystemTray; // instantiates singleton -> registers tray host
        checkMarker.running = true
    }
}