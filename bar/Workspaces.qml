import QtQuick
import Quickshell
import Quickshell.Hyprland

// Displays Hyprland workspace buttons with click-to-switch and urgent highlighting.
Row {
    id: root

    spacing: 4
    height: parent?.implicitHeight ?? 30

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            required property HyprlandWorkspace modelData

            width: 32
            height: parent.height
            radius: 4
            color: {
                if (modelData.urgent) return Theme.wsUrgent
                if (modelData.active) return Theme.wsActive
                return Theme.wsInactive
            }
            opacity: modelData.active ? 1.0 : 0.6

            Behavior on opacity { NumberAnimation { duration: 100 } }
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: modelData.active ? Theme.background : Theme.onSurface
                font.pixelSize: Theme.barFontSize
                font.bold: modelData.active
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
            }
        }
    }
}