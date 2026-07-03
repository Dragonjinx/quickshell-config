import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth status widget — Nerd Font icon, dimmed when disabled.
Item {
    id: root
    implicitWidth: 55

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property int deviceCount: (adapter && adapter.devices) ? adapter.devices.length : 0

    readonly property string iconNerd: root.enabled ? "\uf294" : "\uf293"  // nf-fa-bluetooth_b / nf-fa-bluetooth

    Row {
        anchors.centerIn: parent
        spacing: 6
        opacity: root.enabled ? 1.0 : 0.5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: root.iconNerd
            color: root.enabled ? Theme.primary : Theme.textSurf
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.enabled ? (root.deviceCount > 0 ? root.deviceCount.toString() : "On") : "Off"
            font.pixelSize: Theme.barFontSize
            color: root.enabled ? Theme.barText : Theme.textSurf
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["alacritty", "-e", "bluetoothctl"])
        }
    }
}