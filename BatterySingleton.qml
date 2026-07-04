pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Reads battery info directly from sysfs — no UPower dependency.
Singleton {
    id: root

    property int percentage: -1
    property string status: "Unknown"
    property bool charging: status === "Charging"
    property bool pluggedIn: status === "Full"

    // Time remaining raw values (µWh / µW)
    property int energyNow: 0
    property int powerNow: 0
    property int energyFull: 0

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

    // Read capacity
    Process {
        id: capProc
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true
        stdout: SplitParser {
            onRead: line => { root.percentage = parseInt(line) }
        }
    }

    // Read status
    Process {
        id: statusProc
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: true
        stdout: SplitParser {
            onRead: line => { root.status = line.trim() }
        }
    }

    // Read energy_now
    Process {
        id: energyNowProc
        command: ["cat", "/sys/class/power_supply/BAT0/energy_now"]
        running: true
        stdout: SplitParser {
            onRead: line => { root.energyNow = parseInt(line) }
        }
    }

    // Read power_now
    Process {
        id: powerNowProc
        command: ["cat", "/sys/class/power_supply/BAT0/power_now"]
        running: true
        stdout: SplitParser {
            onRead: line => { root.powerNow = parseInt(line) }
        }
    }

    // Read energy_full
    Process {
        id: energyFullProc
        command: ["cat", "/sys/class/power_supply/BAT0/energy_full"]
        running: true
        stdout: SplitParser {
            onRead: line => { root.energyFull = parseInt(line) }
        }
    }

    // Refresh every 30 seconds
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            capProc.running = true
            statusProc.running = true
            energyNowProc.running = true
            powerNowProc.running = true
            energyFullProc.running = true
        }
    }

    // Nerd Font icon based on state
    readonly property string iconNerd: {
        if (percentage < 0) return ""
        if (pluggedIn) return "\uf1e6"         // nf-fa-plug
        if (charging) return "\uf04e6"          // nf-mdi-battery_charging_100
        if (percentage < 15) return "\uf244"   // nf-fa-battery_0
        if (percentage < 40) return "\uf243"   // nf-fa-battery_1
        if (percentage < 65) return "\uf242"   // nf-fa-battery_2
        if (percentage < 90) return "\uf241"   // nf-fa-battery_3
        return "\uf240"                         // nf-fa-battery_4
    }
}