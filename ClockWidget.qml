import QtQuick
import Quickshell

// Clock display — shows 24h time by default.
// Hover: shows the Gregorian calendar popup.
// Click: shows the full date (DD-MM-YYYY) for 3 seconds.
Item {
    id: root
    implicitWidth: 55
    required property var barWindow

    CalendarPopup {
        id: calendarPopup
        anchorWindow: root.barWindow
        open: mouseArea.containsMouse
    }

    // Date display on click
    property bool showDate: false

    function showDateTemporarily() {
        showDate = true
        dateTimer.restart()
    }

    Timer {
        id: dateTimer
        interval: 3000
        onTriggered: root.showDate = false
    }

    readonly property string fullDate: Qt.formatDateTime(new Date(), "dd.MM.yyyy")

    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.showDate ? root.fullDate : TimeSingleton.time
            font.pixelSize: Theme.barFontSize
            font.bold: true
            color: Theme.barText
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.showDateTemporarily()
    }
}