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

    // --- Connected device detection via nmcli (more reliable than Repeater) ---
    property bool connected: false
    property bool isWifi: false
    property int signalPct: 0

    // Single nmcli call to check wifi connection state
    Process {
        id: netCheckProc
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list | grep '^yes' | head -1"]
        running: true  // runs at construction, before widget renders

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

        // If no wifi output, check for ethernet
        onExited: function(code, status) {
            if (code !== 0) {
                ethCheckProc.running = true
            }
        }
    }

    Process {
        id: ethCheckProc
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE device status | grep -E ':ethernet:connected$' | head -1"]
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

    readonly property string networkDevices: {
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

    // --- Airplane mode detection ---
    property bool airplaneMode: false

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

    // --- NM state monitor (catches wake-from-sleep, reconnects, disconnects) ---
    // nmcli monitor prints a line on every NM state change, including after suspend.
    // This is more reliable than a periodic timer alone.
    Process {
        id: nmMonitor
        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                // Any NM state change triggers a re-check
                netCheckProc.running = true
            }
        }

        onExited: function(code, status) {
            // If monitor exits (e.g. NM restarted), restart it
            if (code !== 0) {
                nmMonitor.running = true
            }
        }
    }

    // --- Periodic refresh fallback (catches signal strength changes) ---
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: netCheckProc.running = true
    }

    readonly property string iconNerd: {
        if (root.airplaneMode) return "󰀝"     // md-airplane
        if (!root.connected) return "󰌺"      // md-link_variant_off
        if (root.isWifi) {
            if (root.signalPct >= 66) return "󰤥"  // md-wifi_strength_3 (3 bars)
            if (root.signalPct >= 33) return "󰤢"  // md-wifi_strength_2 (2 bars)
            if (root.signalPct > 0)  return "󰤟"  // md-wifi_strength_1 (1 bar)
            return "󰤭"                         // md-wifi_strength_off (0 bars)
        }
        return "󰈀"                           // md-ethernet
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
        visible: root.hovered && (root.connected || root.airplaneMode)
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

                Text {
                    text: root.networkDevices
                    font.pixelSize: 12
                    color: Theme.barText
                    visible: root.networkDevices !== ""
                    lineHeight: 1.6
                }

                Text {
                    text: root.airplaneMode ? "Airplane mode" : "No active connections"
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
            font.pixelSize: Theme.mdiFontSize
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