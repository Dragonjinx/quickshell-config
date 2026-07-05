import QtQuick
import Quickshell

// Power menu button — click to launch wlogout.
Item {
    id: root
    implicitWidth: iconText.implicitWidth + 12

    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Theme.fontFam
        font.pixelSize: Theme.barFontSize
        text: ""  // nf-fa-power_off
        color: Theme.barText
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["wlogout"])
        }
    }
}