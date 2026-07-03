import QtQuick
import Quickshell
import Quickshell.Widgets

// Clock display using TimeSingleton and system icon.
Row {
    id: root

    spacing: 6
    height: parent?.implicitHeight ?? 30

    IconImage {
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: 14
        source: Quickshell.iconPath("clock-symbolic")
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: TimeSingleton.time
            font.pixelSize: Theme.barFontSize
            font.bold: true
            color: Theme.barText
        }
        Text {
            text: TimeSingleton.date
            font.pixelSize: Theme.barFontSize - 2
            color: Theme.outline
            visible: false  // show only on hover — toggle as needed
        }
    }
}