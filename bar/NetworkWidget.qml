import QtQuick
import Quickshell
import Quickshell.Widgets

// Network status widget — shows wifi signal or ethernet indicator.
// Uses the Quickshell.Networking API (NetworkManager backend).
Item {
    id: root

    implicitWidth: networkRow.implicitWidth + 12
    height: parent?.implicitHeight ?? 30

    readonly property var primaryDevice: {
        // Find the first active wifi or wired device
        const devices = Networking.devices
        for (let i = 0; i < devices.length; i++) {
            const dev = devices[i]
            if (dev.activeConnection || dev.state === 100 /* activated */) return dev
        }
        return null
    }

    readonly property string iconName: {
        if (!primaryDevice) return "network-offline-symbolic"
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

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 14
            source: Quickshell.iconPath(root.iconName)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.primaryDevice) return "Offline"
                if (root.primaryDevice.deviceType === DeviceType.Wifi) {
                    const wifi = root.primaryDevice
                    return (wifi.ssid ?? wifi.name ?? "WiFi") + " " + (wifi.strength ?? 0) + "%"
                }
                return "Wired"
            }
            font.pixelSize: Theme.barFontSize
            color: root.primaryDevice ? Theme.barText : Theme.error
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