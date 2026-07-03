import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Bluetooth

// Bluetooth status widget — shows connected device count or icon.
// Maintains consistent layout width regardless of adapter state.
// When disabled, content is dimmed (opacity 0.5) but spacing stays the same.
Item {
    id: root

    implicitWidth: 60
    height: parent?.implicitHeight ?? 30

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property int deviceCount: adapter ? adapter.devices.length : 0

    readonly property string iconName: {
        if (!enabled) return "bluetooth-disabled-symbolic"
        if (deviceCount > 0) return "bluetooth-active-symbolic"
        return "bluetooth-symbolic"
    }

    Row {
        id: btRow
        anchors.centerIn: parent
        spacing: 6
        opacity: root.enabled ? 1.0 : 0.5

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 14
            source: Quickshell.iconPath(root.iconName)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.enabled ? (root.deviceCount > 0 ? root.deviceCount.toString() : "On") : "Off"
            font.pixelSize: Theme.barFontSize
            color: root.enabled ? Theme.barText : Theme.outline
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