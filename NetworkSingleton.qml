pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick

// Centralized network state — one instance shared across all bar instances.
// Manages nmcli processes and state (connected, isWifi, signalPct, airplaneMode)
// once, rather than duplicating them per display.
Singleton {
    id: root

    property bool connected: false
    property bool isWifi: false
    property int signalPct: 0
    property bool airplaneMode: false

    // ── Wifi connection check ──────────────────────────────
    Process {
        id: netCheckProc
        // grep -m1 prints only the first active wifi line, and (unlike a trailing
        // `head -1`) still exits non-zero when nothing matches. A head -1 here
        // always exits 0, which masked the disconnect and left the widget stuck
        // on the last known signal instead of reporting Offline.
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list | grep -m1 '^yes'"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                var parts = line.trim().split(":")
                if (parts.length >= 3) {
                    root.connected = true
                    root.isWifi = true
                    root.signalPct = parseInt(parts[2]) || 0
                }
            }
        }

        onExited: function(code, status) {
            if (code !== 0) {
                ethCheckProc.running = true
            }
        }
    }

    // ── Ethernet connection check ──────────────────────────
    Process {
        id: ethCheckProc
        // Same -m1 rationale as netCheckProc: preserves a non-zero exit code
        // when no interface is connected, so the disconnect path runs.
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE device status | grep -m1 -E ':ethernet:connected$'"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                var parts = line.trim().split(":")
                if (parts.length >= 3) {
                    root.connected = true
                    root.isWifi = false
                }
            }
        }

        onExited: function(code, status) {
            if (code !== 0) {
                root.connected = false
                root.isWifi = false
                root.signalPct = 0
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

    // ── React to Quickshell Networking service changes ─────
    Connections {
        target: Networking

        function onWifiEnabledChanged() {
            rfkillCheck.running = true
            netCheckProc.running = true
        }

        function onWifiHardwareEnabledChanged() {
            rfkillCheck.running = true
            netCheckProc.running = true
        }
    }

    // ── NM state monitor (sleep/wake, reconnects) ──────────
    Process {
        id: nmMonitor
        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                netCheckProc.running = true
            }
        }

        onExited: function(code, status) {
            if (code !== 0) {
                nmMonitor.running = true
            }
        }
    }

    // ── Periodic refresh fallback ──────────────────────────
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: netCheckProc.running = true
    }

    // ── Device info string for tooltips (from Quickshell services) ──
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
