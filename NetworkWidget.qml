import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// Network status widget — shows wifi or ethernet indicator via Nerd Font.
// Uses a hidden Repeater to iterate Networking.devices (ObjectModel),
// and a Process to get the active connection name from nmcli.
//
// Default: icon + signal strength. Hover: popup with network name.
Item {
    id: root
    implicitWidth: contentRow.implicitWidth + 12
    required property var barWindow
    required property var barContent

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
                        root.isWifi = modelData.type === 1
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
        if (!root.connected) return ""      // nf-fa-chain_broken
        if (root.isWifi) return ""           // nf-fa-wifi
        return "󰈀"                           // nf-mdi-lan (ethernet)
    }

    // Pre-compute left edge via parent chain
    readonly property real iconLeft: {
        var x = 0;
        var item = root;
        while (item && item !== root.barContent) {
            x += item.x;
            item = item.parent;
        }
        return x;
    }

    // --- Tooltip popup ---
    property bool hovered: false

    PopupWindow {
        id: tooltip
        visible: root.hovered && root.connected && root.isWifi
        grabFocus: false

        anchor.window: root.barWindow
        anchor.rect.x: root.iconLeft
        anchor.rect.y: root.barWindow.height + 4

        implicitWidth: Math.min(nameText.implicitWidth + 24, 300)
        implicitHeight: 28
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: Theme.surface
            border.color: Theme.outlineVar
            border.width: 1

            Text {
                id: nameText
                anchors.centerIn: parent
                text: root.netName || "WiFi"
                font.pixelSize: Theme.barFontSize
                color: Theme.barText
            }
        }
    }

    // --- Main content ---
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6
        opacity: root.connected ? 1.0 : 0.5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            font.pixelSize: Theme.barFontSize
            text: root.iconNerd
            color: root.connected ? Theme.barText : Theme.textSurf
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.connected) return "Offline"
                if (root.isWifi) return root.signalPct + "%"
                return "Wired"
            }
            font.pixelSize: Theme.barFontSize
            color: root.connected ? Theme.barText : Theme.textSurf
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
