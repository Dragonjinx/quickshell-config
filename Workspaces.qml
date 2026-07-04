import QtQuick
import Quickshell
import Quickshell.Hyprland

// Workspace buttons — always shows 1-5 plus a 6th overflow box for any workspace > 5.
Row {
    id: root
    spacing: 4

    // Build a lookup map from Hyprland.workspaces for quick access
    readonly property var wsMap: {
        const map = {}
        const workspaces = Hyprland.workspaces
        for (let i = 0; i < (workspaces ? workspaces.length : 0); i++) {
            const ws = workspaces[i]
            map[ws.id] = ws
        }
        return map
    }

    readonly property var activeWs: Hyprland.focusedWorkspace

    // Fixed workspaces 1-5
    Repeater {
        model: [1, 2, 3, 4, 5]

        delegate: Rectangle {
            required property int modelData

            readonly property var ws: root.wsMap[modelData]
            readonly property bool isActive: root.activeWs ? root.activeWs.id === modelData : false
            readonly property bool isUrgent: ws ? ws.urgent : false

            width: 32
            height: parent.height
            radius: 4
            color: {
                if (isUrgent) return Theme.wsUrgent
                if (isActive) return Theme.wsActive
                return Theme.wsInactive
            }
            opacity: isActive ? 1.0 : 0.6

            Behavior on opacity { NumberAnimation { duration: 100 } }
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: modelData
                color: isActive ? Theme.bg : Theme.textSurf
                font.pixelSize: Theme.barFontSize
                font.bold: isActive
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Hyprland.dispatch("workspace " + modelData)
                }
            }
        }
    }

    // 6th overflow box — shows active workspace > 5, or a "+" if none active
    Rectangle {
        width: 32
        height: parent.height
        radius: 4

        readonly property bool hasAnyOverflow: {
            const wss = Hyprland.workspaces
            if (!wss) return false
            for (let i = 0; i < wss.length; i++) {
                if (wss[i].id > 5) return true
            }
            return false
        }

        readonly property var overflowActive: root.activeWs && root.activeWs.id > 5 ? root.activeWs : null

        color: overflowActive ? Theme.wsActive : (hasAnyOverflow ? Theme.wsInactive : Theme.wsInactive)
        opacity: overflowActive ? 1.0 : (hasAnyOverflow ? 0.6 : 0.3)

        Behavior on opacity { NumberAnimation { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 100 } }

        Text {
            anchors.centerIn: parent
            text: parent.overflowActive ? parent.overflowActive.id : "+"
            color: parent.overflowActive ? Theme.bg : Theme.textSurf
            font.pixelSize: Theme.barFontSize
            font.bold: parent.overflowActive !== null
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Hyprland.dispatch("workspace 6")
            }
        }
    }
}