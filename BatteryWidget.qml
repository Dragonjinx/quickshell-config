import QtQuick
import Quickshell
import Quickshell.Widgets

// Battery widget — shows icon and percentage. Hidden if no battery found.
Item {
    id: root

    visible: BatterySingleton.percentage >= 0
    implicitWidth: 55
    height: parent ? parent.implicitHeight : 30

    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 6
        opacity: root.visible ? 1.0 : 0.0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: BatterySingleton.pluggedIn ? "🔌" : BatterySingleton.charging ? "⚡" : "🔋"
            font.pixelSize: 10
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