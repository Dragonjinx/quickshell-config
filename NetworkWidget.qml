import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Networking

// Network status widget — shows wifi signal or ethernet indicator.
// Maintains consistent layout width regardless of connection state.
// When offline, content is dimmed (opacity 0.5) but spacing stays the same.
Item {
    id: root

    implicitWidth: 90
    height: parent ? parent.implicitHeight : 30

    readonly property var primaryDevice: {
        const devices = Networking.devices
        for (let i = 0; i < devices.length; i++) {
            const dev = devices[i]
            if (dev.activeConnection || dev.state === 100) return dev
        }
        return null
    }

    readonly property bool connected: primaryDevice !== null

    readonly property string iconEmoji: {
        if (!connected) return "🌐"
        if (primaryDevice.deviceType === DeviceType.Wifi) return "📶"
        return "🔌"
    }

    Row {
        id: networkRow
        anchors.centerIn: parent
        spacing: 6
        opacity: root.connected ? 1.0 : 0.5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.iconEmoji
            font.pixelSize: 11
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.connected) return "Offline"
                if (root.primaryDevice.deviceType === DeviceType.Wifi) {
                    const wifi = root.primaryDevice
                    return (wifi.ssid || wifi.name || "WiFi") + " " + (wifi.strength || 0) + "%"
                }
                return "Wired"
            }
            font.pixelSize: Theme.barFontSize
            color: root.connected ? Theme.barText : Theme.textSurf
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