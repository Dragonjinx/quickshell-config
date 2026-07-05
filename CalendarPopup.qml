import QtQuick
import Quickshell

// Simple Gregorian calendar popup — appears below the clock on hover.
// Non-interactive: just displays the current month grid.
Item {
    id: root

    property bool open: false
    property var anchorWindow: null
    required property var barContent

    // Pre-compute right edge via parent chain
    readonly property real iconRight: {
        var x = 0;
        var item = root;
        while (item && item !== root.barContent) {
            x += item.x;
            item = item.parent;
        }
        return x + root.parent.width;
    }

    readonly property date today: new Date()
    readonly property int currentMonth: today.getMonth()
    readonly property int currentYear: today.getFullYear()
    readonly property int firstDayOfWeek: 1  // Monday

    readonly property int daysInMonth: new Date(currentYear, currentMonth + 1, 0).getDate()
    readonly property int firstDayOffset: {
        const d = new Date(currentYear, currentMonth, 1).getDay()
        return (d - firstDayOfWeek + 7) % 7
    }

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    readonly property var dayHeaders: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    PopupWindow {
        id: popup
        visible: root.open
        grabFocus: false

        anchor.window: root.anchorWindow
        anchor.rect.x: root.iconRight - popup.implicitWidth
        anchor.rect.y: root.anchorWindow.height + 4

        implicitWidth: 260
        implicitHeight: calendarColumn.implicitHeight + 20
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Theme.surface
            border.color: Theme.outlineVar
            border.width: 1

            Column {
                id: calendarColumn
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 8

                // Month/year header
                Text {
                    width: parent.width
                    text: monthNames[root.currentMonth] + " " + root.currentYear
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.barText
                    horizontalAlignment: Text.AlignHCenter
                }

                // Day-of-week headers
                Row {
                    width: parent.width
                    spacing: 2
                    Repeater {
                        model: root.dayHeaders
                        delegate: Text {
                            required property string modelData
                            text: modelData
                            width: (parent.width - 12) / 7
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.outline
                        }
                    }
                }

                // Calendar grid
                Grid {
                    columns: 7
                    columnSpacing: 2
                    rowSpacing: 2
                    width: parent.width

                    Repeater {
                        model: root.firstDayOffset
                        delegate: Item { width: (parent.width - 12) / 7; height: 24 }
                    }

                    Repeater {
                        model: root.daysInMonth

                        delegate: Rectangle {
                            required property int index

                            readonly property int day: index + 1
                            readonly property bool isToday: day === root.today.getDate()

                            width: (parent.width - 12) / 7
                            height: 24
                            radius: 4
                            color: isToday ? Theme.primary : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: day
                                font.pixelSize: 12
                                font.bold: isToday
                                color: isToday ? Theme.onPrim : Theme.barText
                            }
                        }
                    }
                }
            }
        }
    }
}