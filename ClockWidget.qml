import QtQuick
import Quickshell

// Clock display — shows 24h time by default.
// Click: toggles between time and date (DD-MM-YYYY).
// Hover: shows the simple Gregorian calendar.
Item {
    id: root
    implicitWidth: displayText.contentWidth + 16
    required property var barWindow
    required property var barContent

    CalendarPopup {
        id: calendarPopup
        anchorWindow: root.barWindow
        barContent: root.barContent
        open: mouseArea.containsMouse
    }

    property bool showDate: false

    readonly property string displayTime: TimeSingleton.time
    readonly property string displayDate: Qt.formatDateTime(new Date(), "dd.MM.yyyy")

    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: displayText
            anchors.verticalCenter: parent.verticalCenter
            text: root.showDate ? root.displayDate : root.displayTime
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
        onClicked: root.showDate = !root.showDate
    }
}