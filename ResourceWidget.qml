import QtQuick
import Quickshell
import Quickshell.Io

// Resource usage widget — Disk, CPU, and Memory percentages.
// Matches Waybar's hardware group format: D xx% / C xx% / M xx%
// Click: opens btop.
Item {
    id: root
    implicitWidth: contentRow.implicitWidth + 12

    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0

    // Previous CPU ticks for delta calculation
    property int prevIdle: 0
    property int prevTotal: 0

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

    // --- Disk usage via df ---
    Process {
        id: diskProc
        command: ["sh", "-c", "df / | awk 'NR==2 {print $5}' | tr -d '%'"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                var val = parseInt(line.trim())
                if (!isNaN(val)) root.diskUsage = val
            }
        }
    }

    // Refresh every 10 seconds
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            diskProc.running = true
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.spacing.sm

        Text {
            text: "D"
            font.pixelSize: Theme.barFontSize
            color: Theme.outline
        }
        Text {
            text: root.diskUsage + "%"
            font.pixelSize: Theme.barFontSize
            color: root.diskUsage > 85 ? Theme.error : Theme.barText
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