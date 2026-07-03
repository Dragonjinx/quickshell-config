import QtQuick
import Quickshell
import Quickshell.Widgets

// Battery widget — shows icon and percentage. Hidden if no battery found.
Item {
    id: root

    visible: BatterySingleton.percentage >= 0
    implicitWidth: batteryRow.implicitWidth + 12
    height: parent?.implicitHeight ?? 30

    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 6

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 14
            source: Quickshell.iconPath(BatterySingleton.iconName)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: BatterySingleton.displayText
            font.pixelSize: Theme.barFontSize
            color: Theme.barText
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