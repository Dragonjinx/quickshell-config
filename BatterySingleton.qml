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

    readonly property string displayText: {
        if (percentage < 0) return "\u2014"
        return Math.round(percentage) + "%"
    }

    // Read capacity
    Process {
        id: capProc
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                root.percentage = parseInt(line)
            }
        }
    }

    // Read status
    Process {
        id: statusProc
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                root.status = line.trim()
            }
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
        }
    }

    // Nerd Font icon based on state
    readonly property string iconNerd: {
        if (percentage < 0) return ""
        if (pluggedIn) return "\uf1e6"         // nf-fa-plug
        if (charging) return "\uf0e7"          // nf-fa-bolt
        if (percentage < 15) return "\uf244"   // nf-fa-battery_0
        if (percentage < 40) return "\uf243"   // nf-fa-battery_1
        if (percentage < 65) return "\uf242"   // nf-fa-battery_2
        if (percentage < 90) return "\uf241"   // nf-fa-battery_3
        return "\uf240"                         // nf-fa-battery_4
    }
}