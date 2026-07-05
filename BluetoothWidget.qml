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

    readonly property int connectedCount: {
        if (!adapter || !adapter.devices) return 0;
        var vals = adapter.devices.values;
        var count = 0;
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].connected) count++;
        }
        return count;
    }

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

    // --- Hover popup (simple, matching NetworkWidget pattern) ---
    property bool hovered: false

    PopupWindow {
        id: tooltip
        visible: root.hovered
        grabFocus: false

        anchor.window: root.barWindow
        anchor.rect.x: root.iconLeft
        anchor.rect.y: root.barWindow.height + 4

        implicitWidth: Math.min(popupText.implicitWidth + 24, 300)
        implicitHeight: 28
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: Theme.surface
            border.color: Theme.outlineVar
            border.width: 1

            Text {
                id: popupText
                anchors.centerIn: parent
                text: root.enabled ? (root.connectedCount > 0 ? "Bluetooth Connected" : "Bluetooth On") : "Bluetooth Off"
                font.pixelSize: Theme.barFontSize
                color: Theme.barText
            }
        }
    }

    // --- Main icon ---
    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Theme.fontFam
        font.pixelSize: Theme.barFontSize
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