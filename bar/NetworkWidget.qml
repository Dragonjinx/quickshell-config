import QtQuick
import Quickshell
import Quickshell.Widgets

// Network status widget — shows wifi signal or ethernet indicator.
// Maintains consistent layout width regardless of connection state.
// When offline, content is dimmed (opacity 0.5) but spacing stays the same.
Item {
    id: root

    // Fixed width so the bar doesn't shift when connectivity changes
    implicitWidth: 90
    height: parent?.implicitHeight ?? 30

    readonly property var primaryDevice: {
        const devices = Networking.devices
        for (let i = 0; i < devices.length; i++) {
            const dev = devices[i]
            if (dev.activeConnection || dev.state === 100) return dev
        }
        return null
    }

    readonly property bool connected: primaryDevice !== null

    readonly property string iconName: {
        if (!connected) return "network-offline-symbolic"
        if (primaryDevice.deviceType === DeviceType.Wifi) {
            const wifi = primaryDevice
            const strength = wifi.strength ?? 0
            if (strength < 25) return "network-wireless-signal-weak-symbolic"
            if (strength < 50) return "network-wireless-signal-ok-symbolic"
            if (strength < 75) return "network-wireless-signal-good-symbolic"
            return "network-wireless-signal-excellent-symbolic"
        }
        return "network-wired-symbolic"
    }

    Row {
        id: networkRow
        anchors.centerIn: parent
        spacing: 6
        opacity: root.connected ? 1.0 : 0.5

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 14
            source: Quickshell.iconPath(root.iconName)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.connected) return "Offline"
                if (root.primaryDevice.deviceType === DeviceType.Wifi) {
                    const wifi = root.primaryDevice
                    return (wifi.ssid ?? wifi.name ?? "WiFi") + " " + (wifi.strength ?? 0) + "%"
                }
                return "Wired"
            }
            font.pixelSize: Theme.barFontSize
            color: root.connected ? Theme.barText : Theme.outline
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["alacritty", "-e", "nmtui"])
        }
    }
}