import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// Network status widget — shows wifi or ethernet indicator via Nerd Font.
// Hover reveals a popup with device and network info.
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

    // --- Pre-computed device info for the popup ---
    readonly property string networkDevices: {
        if (!Networking || !Networking.devices) return "";
        var devs = Networking.devices.values;
        var lines = [];
        for (var i = 0; i < devs.length; i++) {
            var dev = devs[i];
            if (dev.connected) {
                var devName = dev.name || "Device";
                var typeIcon = dev.type === 1 ? "" : "󰈀";
                var netName = "";
                if (dev.networks) {
                    var nets = dev.networks.values;
                    for (var j = 0; j < nets.length; j++) {
                        if (nets[j].connected) {
                            netName = nets[j].name || "";
                            // For wifi, append signal
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

    readonly property int connectedCount: {
        if (!Networking || !Networking.devices) return 0;
        var devs = Networking.devices.values;
        var count = 0;
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].connected) count++;
        }
        return count;
    }

    // --- Get network name and signal via nmcli (for bar display) ---
    Process {
        id: nmcliProc
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list | grep '^yes' | head -1"]
        running: root.connected && root.isWifi

        stdout: SplitParser {
            onRead: function(line) {
                var parts = line.trim().split(":")
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
        visible: root.hovered && root.connected
        grabFocus: false

        anchor.window: root.barWindow
        anchor.rect.x: root.iconLeft
        anchor.rect.y: root.barWindow.height + 4

        implicitWidth: Math.min(300, Math.max(180, deviceColumn.implicitWidth + 20))
        implicitHeight: deviceColumn.implicitHeight + 20
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: Theme.surface
            border.color: Theme.outlineVar
            border.width: 1

            Column {
                id: deviceColumn
                anchors {
                    left: parent.left; leftMargin: 10
                    top: parent.top; topMargin: 8
                    right: parent.right; rightMargin: 10
                }
                spacing: 3


                // --- Device list ---
                Text {
                    text: root.networkDevices
                    font.pixelSize: 12
                    color: Theme.barText
                    visible: root.networkDevices !== ""
                    lineHeight: 1.6
                }

                // --- Empty state ---
                Text {
                    text: "No active connections"
                    font.pixelSize: 12
                    color: Theme.textSurf
                    visible: root.networkDevices === ""
                    height: 20
                }
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