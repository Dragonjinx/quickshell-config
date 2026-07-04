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
            id: delegateRect
            required property int modelData

            readonly property var ws: root.wsMap[modelData]
            readonly property bool isActive: root.activeWs ? root.activeWs.id === modelData : false
            readonly property bool isUrgent: ws ? ws.urgent : false
            property bool hovered: false
            property int extraPad: 0

            implicitWidth: txt.implicitWidth + 16 + extraPad
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

            Behavior on opacity { NumberAnimation { duration: 100 } }
            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on radius { NumberAnimation { duration: 100 } }

            // Animate width smoothly in both directions
            onIsActiveChanged: {
                extraPadAnim.stop()
                extraPadAnim.to = isActive ? 14 : 0
                extraPadAnim.start()
            }

            NumberAnimation {
                id: extraPadAnim
                target: delegateRect
                property: "extraPad"
                duration: 150
                easing.type: Easing.InOutQuad
            }

            Text {
                id: txt
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
        implicitWidth: overflowTxt.implicitWidth + 16
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
            id: overflowTxt
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