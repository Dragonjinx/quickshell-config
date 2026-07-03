import QtQuick
import Quickshell
import Quickshell.Networking

// Network status widget — shows wifi or ethernet indicator via Nerd Font.
// Fixed width, dimmed to 0.5 opacity when offline.
Item {
    id: root
    implicitWidth: 90

    // Find the connected network across all devices
    readonly property var primaryDevice: {
        const devices = Networking.devices
        for (let i = 0; i < devices.length; i++) {
            const dev = devices[i]
            if (dev.connected) return dev
        }
        return null
    }

    // Find the connected network on the primary device
    readonly property var connectedNetwork: {
        if (!primaryDevice) return null
        const nets = primaryDevice.networks
        if (!nets) return null
        for (let i = 0; i < nets.length; i++) {
            if (nets[i].connected) return nets[i]
        }
        return null
    }

    readonly property bool connected: primaryDevice !== null

    readonly property string iconNerd: {
        if (!connected) return "\uf127"           // nf-fa-chain_broken
        if (primaryDevice.type === DeviceType.Wifi) return "\uf1eb"  // nf-fa-wifi
        return "\uf6ff"                           // nf-fa-ethernet
    }

    readonly property int signalPct: {
        if (!connectedNetwork) return 0
        return Math.round(connectedNetwork.signalStrength * 100)
    }

    Row {
        anchors.centerIn: parent
        spacing: 6
        opacity: root.connected ? 1.0 : 0.5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: root.iconNerd
            color: root.connected ? Theme.barText : Theme.textSurf
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.connected) return "Offline"
                if (root.primaryDevice.type === DeviceType.Wifi) {
                    return (root.connectedNetwork ? root.connectedNetwork.name : "WiFi")
                         + " " + root.signalPct + "%"
                }
                return "Wired"
            }
            font.pixelSize: Theme.barFontSize
            color: root.connected ? Theme.barText : Theme.textSurf
            elide: Text.ElideRight
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