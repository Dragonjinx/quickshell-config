import QtQuick
import Quickshell

// Network status widget — shows wifi or ethernet indicator via Nerd Font.
// All data state lives in NetworkSingleton (shared across all bars).
Item {
    id: root
    implicitWidth: contentRow.implicitWidth + 12

    required property var barWindow
    required property var barContent

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

    readonly property string iconNerd: {
        if (NetworkSingleton.airplaneMode) return "󰀝"     // md-airplane
        if (!NetworkSingleton.connected) return "󰌺"      // md-link_variant_off
        if (NetworkSingleton.isWifi) {
            var sig = NetworkSingleton.signalPct
            if (sig >= 66) return "󰤥"  // md-wifi_strength_3
            if (sig >= 33) return "󰤢"  // md-wifi_strength_2
            if (sig > 0)   return "󰤟"  // md-wifi_strength_1
            return "󰤭"                 // md-wifi_strength_off
        }
        return "󰈀"                       // md-ethernet
    }

    // ── Tooltip popup ──────────────────────────────────────
    property bool hovered: false

    PopupWindow {
        id: tooltip
        visible: root.hovered && (NetworkSingleton.connected || NetworkSingleton.airplaneMode)
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
                    left: parent.left; leftMargin: Theme.padding.sm
                    top: parent.top; topMargin: Theme.padding.sm
                    right: parent.right; rightMargin: Theme.padding.sm
                }
                spacing: 3

                Text {
                    text: NetworkSingleton.deviceInfo
                    font.pixelSize: 12
                    color: Theme.barText
                    visible: NetworkSingleton.deviceInfo !== ""
                    lineHeight: 1.6
                }

                Text {
                    text: NetworkSingleton.airplaneMode ? "Airplane mode" : "No active connections"
                    font.pixelSize: 12
                    color: Theme.textSurf
                    visible: NetworkSingleton.deviceInfo === ""
                    height: 20
                }
            }
        }
    }

    // ── Main content ───────────────────────────────────────
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6
        opacity: NetworkSingleton.connected ? 1.0 : 0.5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            font.pixelSize: Theme.mdiFontSize
            text: root.iconNerd
            color: NetworkSingleton.connected ? Theme.barText : Theme.textSurf
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!NetworkSingleton.connected) return "Offline"
                if (NetworkSingleton.isWifi) return NetworkSingleton.signalPct + "%"
                return "Wired"
            }
            font.pixelSize: Theme.barFontSize
            color: NetworkSingleton.connected ? Theme.barText : Theme.textSurf
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
