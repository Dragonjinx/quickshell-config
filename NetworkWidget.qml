import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// Network status widget — shows wifi or ethernet indicator via Nerd Font.
// Uses a hidden Repeater to iterate Networking.devices (ObjectModel),
// and a Process to get the active connection name from nmcli.
Item {
    id: root
    implicitWidth: 90

    // --- Connected device detection via hidden Repeater ---
    property bool connected: false
    property bool isWifi: false
    property string netName: ""
    property int signalPct: 0

    Item {
        Repeater {
            model: Networking.devices

            delegate: Item {
                required property var modelData

                onModelDataChanged: {
                    if (modelData && modelData.connected) {
                        root.connected = true
                        root.isWifi = modelData.type === 1  // 1 = Wifi
                    }
                }

                Component.onCompleted: {
                    if (modelData && modelData.connected) {
                        root.connected = true
                        root.isWifi = modelData.type === 1
                    }
                }
            }
        }
    }

    // --- Get network name and signal via nmcli ---
    Process {
        id: nmcliProc
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list | grep '^yes' | head -1"]
        running: root.connected && root.isWifi

        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split(":")
                if (parts.length >= 3) {
                    root.netName = parts[1] || "WiFi"
                    root.signalPct = parseInt(parts[2]) || 0
                }
            }
        }
    }

    // Refresh network info every 10 seconds
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            if (root.connected && root.isWifi) {
                nmcliProc.running = true
            }
        }
    }

    readonly property string iconNerd: {
        if (!root.connected) return "\uf127"      // nf-fa-chain_broken
        if (root.isWifi) return "\uf1eb"           // nf-fa-wifi
        return "\uf6ff"                             // nf-fa-ethernet
    }

    property bool hovered: false

    Row {
        anchors.centerIn: parent
        spacing: 6
        opacity: root.connected ? 1.0 : 0.5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: root.iconNerd
            color: root.connected ? Theme.barText : Theme.textSurf
        }

        // Default: signal strength. On hover: network name.
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.connected) return "Offline"
                if (root.hovered && root.isWifi) return root.netName || "WiFi"
                if (root.isWifi) return root.signalPct + "%"
                return "Wired"
            }
            font.pixelSize: Theme.barFontSize
            color: root.connected ? Theme.barText : Theme.textSurf
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: {
            Quickshell.execDetached(["alacritty", "-e", "nmtui"])
        }
    }
}