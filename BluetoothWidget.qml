import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets

// Bluetooth status widget — Nerd Font icon, dimmed when disabled.
// Hover reveals a popup with connected and paired device lists.
// Icons: 󰂱 connected, 󰂲 disabled/off, 󰂯 on (no connections)
Item {
    id: root
    implicitWidth: iconText.implicitWidth + 12

    required property var barWindow
    required property var barContent

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter ? adapter.enabled : false

    // --- Pre-computed device info ---
    readonly property string connectedText: {
        if (!adapter || !adapter.devices) return "";
        var vals = adapter.devices.values;
        var lines = [];
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].connected) {
                var name = vals[i].name || vals[i].deviceName || "Unknown";
                lines.push("󰂱  " + name);
            }
        }
        return lines.join("\n");
    }

    readonly property string pairedText: {
        if (!adapter || !adapter.devices) return "";
        var vals = adapter.devices.values;
        var lines = [];
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].paired && !vals[i].connected) {
                var name = vals[i].name || vals[i].deviceName || "Unknown";
                lines.push(name);
            }
        }
        return lines.join("\n");
    }

    readonly property int connectedCount: {
        if (!adapter || !adapter.devices) return 0;
        var vals = adapter.devices.values;
        var count = 0;
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].connected) count++;
        }
        return count;
    }

    readonly property int pairedDisconnectedCount: {
        if (!adapter || !adapter.devices) return 0;
        var vals = adapter.devices.values;
        var count = 0;
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].paired && !vals[i].connected) count++;
        }
        return count;
    }

    // Airplane mode is detected centrally via NetworkSingleton
    readonly property string iconNerd: !root.enabled ? "󰂲" : root.connectedCount > 0 ? "󰂱" : "󰂯"

    // Walk parent chain to compute left edge within barContent
    readonly property real iconLeft: {
        var x = 0;
        var item = root;
        while (item && item !== root.barContent) {
            x += item.x;
            item = item.parent;
        }
        return x;
    }

    // --- Hover state ---
    property bool hovered: false

    // --- Hover popup ---
    PopupWindow {
        id: tooltip
        visible: root.hovered
        grabFocus: false

        anchor.window: root.barWindow
        anchor.rect.x: root.iconLeft
        anchor.rect.y: root.barWindow.height + 4

        implicitWidth: Math.min(240, Math.max(160, deviceColumn.implicitWidth + 20))
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
                    left: parent.left; leftMargin: Theme.padding.sm
                    top: parent.top; topMargin: Theme.padding.sm
                    right: parent.right; rightMargin: Theme.padding.sm
                }
                spacing: 3

                // --- Header ---
                Text {
                    text: "󰂯 Bluetooth  " + (root.enabled ? (root.connectedCount > 0 ? "Connected" : "On") : "Off")
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.barText
                    bottomPadding: 4
                }

                // --- Connected devices ---
                Text {
                    text: root.connectedText
                    font.pixelSize: 12
                    color: Theme.barText
                    visible: root.connectedText !== ""
                    lineHeight: 1.6
                }

                // --- Separator ---
                Rectangle {
                    height: 1
                    color: Theme.outlineVar
                    visible: root.connectedCount > 0 && root.pairedDisconnectedCount > 0
                    width: parent.width
                }

                // --- Paired (disconnected) devices ---
                Text {
                    text: root.pairedText
                    font.pixelSize: 12
                    color: Theme.textSurf
                    opacity: 0.55
                    visible: root.pairedText !== ""
                    lineHeight: 1.5
                }

                // --- Empty state ---
                Text {
                    text: NetworkSingleton.airplaneMode ? "Airplane mode" : (root.enabled ? "No paired devices" : "Bluetooth disabled")
                    font.pixelSize: 12
                    color: Theme.textSurf
                    visible: root.connectedText === "" && root.pairedText === ""
                    height: 20
                }
            }
        }
    }

    // --- Main icon ---
    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Theme.fontFam
        font.pixelSize: Theme.mdiFontSize
        text: root.iconNerd
        color: root.enabled ? Theme.primary : Theme.textSurf
        opacity: root.enabled ? 1.0 : 0.5
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: {
            Quickshell.execDetached(["alacritty", "-e", "bluetoothctl"])
        }
    }
}
