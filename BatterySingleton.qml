pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Reads battery info directly from sysfs — no UPower dependency.
// Auto-detects the battery device name (BAT0, BAT1, etc.) and
// falls back to charge_now/current_now/charge_full if energy_* files don't exist.
Singleton {
    id: root

    property int percentage: -1
    property string status: "Unknown"
    property bool charging: status === "Charging"
    property bool pluggedIn: status === "Full"

    // Time remaining raw values (µWh / µW or µAh / µA)
    property int energyNow: 0
    property int powerNow: 0
    property int energyFull: 0

    // Power reading for the "P" bar widget (µV and µA -> watches)
    property int currentNow: 0
    property int voltageNow: 0

    // True power draw/charge in watts; -1 when unavailable (e.g. battery full on AC).
    readonly property real powerWatts: {
        if (powerNow > 0) return powerNow / 1000000.0          // power_now is µW
        if (voltageNow > 0 && currentNow > 0) return (voltageNow * currentNow) / 1e12  // µV x µA
        return -1
    }

    // Auto-detected battery device name
    property string batteryName: "BAT0"

    readonly property string displayText: {
        if (percentage < 0) return "\u2014"
        return Math.round(percentage) + "%"
    }

    // Estimated time remaining in hours (as decimal)
    readonly property real hoursRemaining: {
        if (energyNow <= 0 || powerNow <= 0) return -1
        if (charging) {
            // time to full = (energyFull - energyNow) / powerNow
            var remaining = energyFull - energyNow
            return remaining / powerNow
        }
        // time to empty = energyNow / powerNow
        return energyNow / powerNow
    }

    // Formatted as "Xh Ym"
    readonly property string timeRemainingText: {
        if (hoursRemaining < 0) return "\u2014"
        var h = Math.floor(hoursRemaining)
        var m = Math.round((hoursRemaining - h) * 60)
        if (charging) return h + "h " + m + "m \u2191"  // upward arrow for charging
        return h + "h " + m + "m"
    }

    // Detect battery name and energy vs charge files at startup
    Process {
        id: detectProc
        command: ["sh", "-c", "ls /sys/class/power_supply/ | grep -E '^BAT' | head -1 || echo BAT0"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                var name = line.trim()
                if (name !== "") {
                    root.batteryName = name
                    readBattery.running = true
                }
            }
        }
    }

    // Single process to read all battery values atomically
    Process {
        id: readBattery
        command: ["sh", "-c", "BAT=" + root.batteryName + "; " +
            "CAP=$(cat /sys/class/power_supply/$BAT/capacity 2>/dev/null || echo -1); " +
            "STA=$(cat /sys/class/power_supply/$BAT/status 2>/dev/null || echo Unknown); " +
            "ENOW=$(cat /sys/class/power_supply/$BAT/energy_now 2>/dev/null || cat /sys/class/power_supply/$BAT/charge_now 2>/dev/null || echo 0); " +
            "ENOW=$((ENOW)); " +  // force integer
            "PNOW=$(cat /sys/class/power_supply/$BAT/power_now 2>/dev/null || echo 0); " +
            "PNOW=$((PNOW)); " +
            "INOW=$(cat /sys/class/power_supply/$BAT/current_now 2>/dev/null || echo 0); " +
            "INOW=$((INOW)); " +
            "VNOW=$(cat /sys/class/power_supply/$BAT/voltage_now 2>/dev/null || echo 0); " +
            "VNOW=$((VNOW)); " +
            "EFULL=$(cat /sys/class/power_supply/$BAT/energy_full 2>/dev/null || cat /sys/class/power_supply/$BAT/charge_full 2>/dev/null || echo 0); " +
            "EFULL=$((EFULL)); " +
            "echo \"$CAP|$STA|$ENOW|$PNOW|$EFULL|$INOW|$VNOW\""]
        running: false  // triggered by detect or timer

        stdout: SplitParser {
            onRead: function(line) {
                var parts = line.trim().split("|")
                if (parts.length >= 7) {
                    root.percentage = parseInt(parts[0]) || -1
                    root.status = parts[1] || "Unknown"
                    root.energyNow = parseInt(parts[2]) || 0
                    root.powerNow = parseInt(parts[3]) || 0
                    root.energyFull = parseInt(parts[4]) || 0
                    root.currentNow = parseInt(parts[5]) || 0
                    root.voltageNow = parseInt(parts[6]) || 0
                }
            }
        }
    }

    // Listen for kernel uevents on power supply changes (plug/unplug)
    Process {
        id: udevMonitor
        command: ["sh", "-c", "udevadm monitor --kernel --subsystem-match=power_supply | grep -o --line-buffered 'BAT[0-9]*'"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                readBattery.running = true
            }
        }
    }

    // Refresh periodically as a fallback (catches gradual charge changes)
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: { readBattery.running = true }
    }

    // Nerd Font icon based on state
    readonly property string iconNerd: {
        if (percentage < 0) return ""
        if (pluggedIn) return ""         // nf-fa-plug
        if (charging) return ""          // nf-fa-bolt
        if (percentage < 15) return ""   // nf-fa-battery_0
        if (percentage < 40) return ""   // nf-fa-battery_1
        if (percentage < 65) return ""   // nf-fa-battery_2
        if (percentage < 90) return ""   // nf-fa-battery_3
        return ""                         // nf-fa-battery_4
    }
}