import QtQuick
import Quickshell

// Clock display using TimeSingleton with Nerd Font clock icon.
Row {
    id: root
    spacing: 6

    Text {
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.fontFam
        text: "\uf017"  // nf-fa-clock
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