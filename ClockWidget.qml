import QtQuick
import Quickshell
import Quickshell.Widgets

// Clock display using TimeSingleton.
Row {
    id: root

    spacing: 6
    height: parent ? parent.implicitHeight : 30

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "🕐"
        font.pixelSize: 12
        color: Theme.barText
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: TimeSingleton.time
        font.pixelSize: Theme.barFontSize
        font.bold: true
        color: Theme.barText
    }
}