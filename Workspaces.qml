import QtQuick
import Quickshell
import Quickshell.Hyprland

// Workspace buttons — always shows 1-5 plus a 6th overflow box for any workspace > 5.
// Animation: 100ms transitions on opacity and color, matching Waybar's behaviour.
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
            property bool hovered: false

            width: 32
            height: parent.height
            radius: hovered ? 5 : 4
            color: {
                if (isUrgent) return Theme.wsUrgent
                if (isActive) return Theme.wsActive
                return Theme.wsInactive
            }
            opacity: {
                if (isActive) return 1.0
                if (hovered) return 0.7
                return 0.5
            }
            scale: isActive ? 1.0 : 1.0

            Behavior on opacity { NumberAnimation { duration: 100 } }
            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on radius { NumberAnimation { duration: 100 } }

            // Pop animation when becoming active
            onIsActiveChanged: {
                if (isActive) {
                    scale = 1.15
                    popBack.start()
                }
            }

            NumberAnimation {
                id: popBack
                target: parent
                property: "scale"
                to: 1.0
                duration: 150
                easing.type: Easing.OutBack
            }

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
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                onClicked: {
                    Hyprland.dispatch("workspace " + modelData)
                }
            }
        }
    }

    // 6th overflow box — only visible when a workspace > 5 is active
    Rectangle {
        width: 32
        height: parent.height
        visible: root.activeWs && root.activeWs.id > 5

        readonly property var overflowActive: root.activeWs && root.activeWs.id > 5 ? root.activeWs : null
        property bool hovered: false

        color: Theme.wsActive
        radius: hovered ? 5 : 4
        opacity: hovered ? 0.7 : 1.0

        Behavior on opacity { NumberAnimation { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on radius { NumberAnimation { duration: 100 } }

        Text {
            anchors.centerIn: parent
            text: parent.overflowActive ? parent.overflowActive.id : "+"
            color: Theme.bg
            font.pixelSize: Theme.barFontSize
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: parent.hovered = true
            onExited: parent.hovered = false
            onClicked: {
                Hyprland.dispatch("workspace 6")
            }
        }
    }
}