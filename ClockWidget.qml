import QtQuick
import Quickshell

// Clock display — shows 24h time by default.
// Click: toggles between time and date (DD-MM-YYYY).
// Hover: shows the Gregorian calendar popup with a 200ms delay.
Item {
    id: root
    implicitWidth: displayText.contentWidth + 16
    required property var barWindow

    // Hover tracking: open calendar after 200ms
    // CalendarPopup handles its own closing (stays open while mouse is over it)
    property bool hovered: false

    Timer {
        id: openTimer
        interval: 200
        onTriggered: {
            if (root.hovered) {
                calendarPopup.open = true
            }
        }
    }

    CalendarPopup {
        id: calendarPopup
        anchorWindow: root.barWindow
    }

    // Toggle between time and date on click
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
        onEntered: {
            root.hovered = true
            openTimer.start()
        }
        onExited: {
            root.hovered = false
            calendarPopup.open = false
        }
        onClicked: root.showDate = !root.showDate
    }
}