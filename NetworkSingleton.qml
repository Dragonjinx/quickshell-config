pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick

// Centralized network state — one instance shared across all bar instances.
//
// Single source of truth: the NM-backed Quickshell.Networking service.
// connected / isWifi / signalPct are all read straight off Networking.devices
// and recomputed on real change signals. This replaces the old two-process
// nmcli grep pipeline, whose wifi-check / eth-check processes raced and could
// clobber a fresh "connected" with a stale "Offline" (notably when switching
// networks — the whole reason this was rewritten).
Singleton {
    id: root

    property bool connected: false
    property bool isWifi: false
    property int signalPct: 0
    property bool airplaneMode: false

    // ── Recompute everything from Networking.devices ───────
    // Idempotent; safe to call on any change signal or the nmcli monitor pulse.
    // Signal stays non-granular: we just take the connected wifi network's
    // strength rounded to a percentage, same as before.
    function refresh() {
        var any = false
        var wifi = false
        var sig = 0

        if (Networking && Networking.devices) {
            var devs = Networking.devices.values
            for (var i = 0; i < devs.length; i++) {
                var dev = devs[i]
                if (!dev || !dev.connected) continue

                any = true

                if (dev.type === 1) { // wifi device
                    wifi = true
                    if (dev.networks) {
                        var nets = dev.networks.values
                        for (var j = 0; j < nets.length; j++) {
                            var n = nets[j]
                            if (n.connected && n.signalStrength !== undefined) {
                                sig = Math.round(n.signalStrength * 100)
                                break
                            }
                        }
                    }
                }
            }
        }

        root.connected = any
        root.isWifi = wifi
        root.signalPct = sig
    }

    // ── React to real change signals on each device ────────
    // Unlike the old hidden-Repeater + modelData approach (which only fired on
    // object add/remove), these fire when an existing device's connection state
    // changes — including a same-device AP switch that previously went unnoticed.
    Repeater {
        model: Networking.devices

        delegate: Item {
            required property var modelData

            Connections {
                target: modelData
                function onConnectedChanged() { root.refresh() }
                function onStateChanged()     { root.refresh() }
            }
        }
    }

    // ── Airplane mode detection ────────────────────────────
    Process {
        id: rfkillCheck
        command: ["sh", "-c", "nmcli radio wifi | grep -Fxq enabled && echo no || echo yes"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                root.airplaneMode = line.trim() === "yes"
            }
        }
    }

    // ── nmcli monitor = event pulse (kept, not a poll) ─────
    // Guarantees a refresh on every NetworkManager DBus state change, so a real
    // transition is never missed even if no QML signal fires for it.
    Process {
        id: nmMonitor
        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                root.refresh()
            }
        }

        onExited: function(code, status) {
            if (code !== 0) {
                nmMonitor.running = true
            }
        }
    }

    // ── Recompute on wifi enable/hardware toggle ───────────
    Connections {
        target: Networking

        function onWifiEnabledChanged() {
            rfkillCheck.running = true
            root.refresh()
        }

        function onWifiHardwareEnabledChanged() {
            rfkillCheck.running = true
            root.refresh()
        }
    }

    // ── Initial consistency check on load ──────────────────
    Component.onCompleted: root.refresh()

    // ── Startup probe: logins start ALREADY connected ──────
    // On logout/login (and some boots) NetworkManager is already connected when
    // quickshell starts, so there are NO change signals and NO nmcli monitor
    // events to trigger a refresh — and the one Component.onCompleted refresh()
    // may run before Networking.devices is populated, leaving us stuck Offline.
    // Re-probe briefly at boot until the model reflects reality, then stop. This
    // is startup-only, so it can't reintroduce the old wifi/eth stale race.
    Timer {
        id: startupProbe
        interval: 250
        repeat: true
        running: true
        property int tries: 0

        onTriggered: {
            tries++
            root.refresh()
            var populated = Networking && Networking.devices
                && Networking.devices.values.length > 0
            // Stop once the model is populated (data is then event-driven),
            // or after a hard cap so a genuinely-offline login still settles.
            if (populated || tries >= 12) running = false
        }
    }

    // ── Device info string for tooltips ────────────────────
    readonly property string deviceInfo: {
        if (!Networking || !Networking.devices) return "";
        var devs = Networking.devices.values;
        var lines = [];
        for (var i = 0; i < devs.length; i++) {
            var dev = devs[i];
            if (dev.connected) {
                var devName = dev.name || "Device";
                var typeIcon = dev.type === 1 ? "󰖩" : "󰈀";
                var netName = "";
                if (dev.networks) {
                    var nets = dev.networks.values;
                    for (var j = 0; j < nets.length; j++) {
                        if (nets[j].connected) {
                            netName = nets[j].name || "";
                            if (dev.type === 1 && nets[j].signalStrength !== undefined) {
                                var sig = Math.round(nets[j].signalStrength * 100);
                                netName += "  " + sig + "%";
                            }
                            break;
                        }
                    }
                }
                var line = typeIcon + "  " + devName;
                if (netName !== "") line += "  —  " + netName;
                lines.push(line);
            }
        }
        return lines.join("\n");
    }
}