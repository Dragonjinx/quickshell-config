import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth status widget — Nerd Font icon, dimmed when disabled.
// Icons match Waybar: 󰂱 connected, 󰂲 disabled/off
Item {
    id: root
    implicitWidth: iconText.implicitWidth + 12

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property int deviceCount: (adapter && adapter.devices) ? adapter.devices.length : 0

    readonly property string iconNerd: root.enabled ? "\uf0909" : "\uf0ab2"  // nf-mdi-bluetooth_connect / nf-mdi-bluetooth_off

    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Theme.fontFam
        text: root.iconNerd
        color: root.enabled ? Theme.primary : Theme.textSurf
        opacity: root.enabled ? 1.0 : 0.5
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["alacritty", "-e", "bluetoothctl"])
        }
    }
}