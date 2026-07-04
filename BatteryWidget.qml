import QtQuick
import Quickshell

// Battery widget — Nerd Font battery icons, hidden if no battery found.
Item {
    id: root
    implicitWidth: contentRow.implicitWidth + 12
    visible: BatterySingleton.percentage >= 0

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: BatterySingleton.iconNerd
            color: BatterySingleton.percentage < 15 ? Theme.error : Theme.barText
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: BatterySingleton.displayText
            font.pixelSize: Theme.barFontSize
            color: BatterySingleton.percentage < 15 ? Theme.error : Theme.barText
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["alacritty", "-e", "btop"])
        }
    }
}