import QtQuick
import Quickshell
import Quickshell.Io

// Resource usage widget — CPU and memory percentages.
// Click: opens btop.
Item {
    id: root
    implicitWidth: contentRow.implicitWidth + 12

    property int cpuUsage: 0
    property int memUsage: 0

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
                // cpu user nice system idle iowait irq softirq steal
                var idle = parseInt(parts[4]) + parseInt(parts[5])  // idle + iowait
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

    // Refresh every 5 seconds
    Timer {
        interval: 5000
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
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: root.cpuUsage + "%"
            font.pixelSize: Theme.barFontSize
            color: root.cpuUsage > 80 ? Theme.error : Theme.barText
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "/"
            color: Theme.outline
            font.pixelSize: Theme.barFontSize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: "\uf2db"  // nf-fa-microchip
            color: Theme.barText
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "/"
            color: Theme.outline
            font.pixelSize: Theme.barFontSize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.memUsage + "%"
            font.pixelSize: Theme.barFontSize
            color: root.memUsage > 80 ? Theme.error : Theme.barText
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["alacritty", "-e", "btop"])
        }
    }
}