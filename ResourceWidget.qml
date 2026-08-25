import QtQuick
import Quickshell
import Quickshell.Io

// Resource usage widget — Power, CPU, and Memory.
// Shows battery drain/charge power (P), CPU %, and Memory %.
// Match Waybar's format: P xxW / C xx% / M xx%
//  - On battery (Discharging): P = real drain in watts (white)
//  - On AC while charging:     P = charge watts (green)
//  - On AC when battery Full:  no current exists -> grey "--"
// Click: opens btop.
Item {
    id: root
    implicitWidth: contentRow.implicitWidth + 12

    property int cpuUsage: 0
    property int memUsage: 0

    // Previous CPU ticks for delta calculation
    property int prevIdle: 0
    property int prevTotal: 0

    // Is there a real, readable power number right now?
    readonly property bool powerAvailable: {
        var s = BatterySingleton.status
        return s === "Discharging" || s === "Charging"
    }
    // Green only when we're on AC and the battery is genuinely charging.
    readonly property bool powerCharging: BatterySingleton.status === "Charging"

    // Formatted power string; "--" in grey when docked/full (no current to read).
    readonly property string powerText: {
        var w = BatterySingleton.powerWatts
        if (!powerAvailable || w < 0) return "\u2014"          // em dash
        return w.toFixed(1) + "W"
    }

    // Power color: white/green/--; "--" uses a dim outline color.
    readonly property color powerColor: {
        if (powerCharging) return Theme.success
        return powerText === "\u2014" ? Theme.outline : Theme.barText
    }

    // --- CPU usage via /proc/stat ---
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                var parts = line.trim().split(/\s+/)
                if (parts.length < 5) return
                var idle = parseInt(parts[4]) + parseInt(parts[5])
                var total = 0
                for (var i = 1; i < parts.length; i++) total += parseInt(parts[i])

                if (root.prevTotal > 0) {
                    var deltaIdle = idle - root.prevIdle
                    var deltaTotal = total - root.prevTotal
                    if (deltaTotal > 0) {
                        root.cpuUsage = Math.round((1 - deltaIdle / deltaTotal) * 100)
                    }
                }
                root.prevIdle = idle
                root.prevTotal = total
            }
        }
    }

    // --- Memory usage via /proc/meminfo ---
    Process {
        id: memProc
        command: ["sh", "-c", "awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {print t, a}' /proc/meminfo"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                var parts = line.trim().split(/\s+/)
                if (parts.length >= 2) {
                    var total = parseInt(parts[0])
                    var avail = parseInt(parts[1])
                    if (total > 0) {
                        root.memUsage = Math.round((1 - avail / total) * 100)
                    }
                }
            }
        }
    }

    // CPU refresh every 10 seconds (battery handled by BatterySingleton's udev watch + timer).
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.spacing.sm

        Text {
            text: "P"
            font.pixelSize: Theme.barFontSize
            color: Theme.outline
        }
        Text {
            text: root.powerText
            font.pixelSize: Theme.barFontSize
            color: root.powerColor
        }

        Text {
            text: "/"
            color: Theme.outline
            font.pixelSize: Theme.barFontSize
        }

        Text {
            text: "C"
            font.pixelSize: Theme.barFontSize
            color: Theme.outline
        }
        Text {
            text: root.cpuUsage + "%"
            font.pixelSize: Theme.barFontSize
            color: root.cpuUsage > 80 ? Theme.error : Theme.barText
        }

        Text {
            text: "/"
            color: Theme.outline
            font.pixelSize: Theme.barFontSize
        }

        Text {
            text: "M"
            font.pixelSize: Theme.barFontSize
            color: Theme.outline
        }
        Text {
            text: root.memUsage + "%"
            font.pixelSize: Theme.barFontSize
            color: root.memUsage > 80 ? Theme.error : Theme.barText
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["kitty", "-e", "btop"])
        }
    }
}