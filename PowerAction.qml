import QtQuick
import QtQuick.Layouts
import Quickshell

// Power action button — used in PowerMenuWidget's action grid.
// Shows an MDI icon + label with hover highlight.
Item {
    id: root
    required property string iconChar
    required property string label
    required property string command
    signal executed()

    Layout.fillWidth: true
    implicitHeight: 64
    Layout.preferredHeight: 64

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: ma.containsMouse ? Theme.surfBright : "transparent"

        Column {
            anchors.centerIn: parent
            spacing: 4

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: Theme.fontFam
                font.pixelSize: 22
                text: root.iconChar
                color: ma.containsMouse ? Theme.primary : Theme.barText
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: Theme.fontFam
                font.pixelSize: 11
                text: root.label
                color: ma.containsMouse ? Theme.primary : Theme.textSurf
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["sh", "-c", root.command])
            root.executed()
        }
    }
}