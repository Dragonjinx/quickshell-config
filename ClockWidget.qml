import QtQuick
import Quickshell

// Clock display using TimeSingleton with Nerd Font clock icon.
// Click to show a Gregorian calendar popup (locale-aware).
Item {
    id: root
    implicitWidth: 55
    required property var barWindow

    CalendarPopup {
        id: calendarPopup
        anchorWindow: root.barWindow
    }

    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: "\uf017"  // nf-fa-clock-o
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

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            calendarPopup.open = !calendarPopup.open
        }
    }
}