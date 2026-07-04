import QtQuick
import Quickshell

// Gregorian calendar popup that appears below the clock.
// Uses locale settings for first day of week and date formatting.
Item {
    id: root

    property bool open: false
    property var anchorWindow: null

    readonly property date today: new Date()
    readonly property int currentMonth: today.getMonth()
    readonly property int currentYear: today.getFullYear()

    // First day of week: 0=Sun, 1=Mon — match LC_TIME=de_DE (Monday)
    readonly property int firstDayOfWeek: 1  // Monday

    // Month navigation
    property int viewMonth: currentMonth
    property int viewYear: currentYear

    function resetView() {
        viewMonth = currentMonth
        viewYear = currentYear
    }

    readonly property int daysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()
    readonly property int firstDayOffset: {
        const d = new Date(viewYear, viewMonth, 1).getDay()  // 0=Sun..6=Sat
        return (d - firstDayOfWeek + 7) % 7
    }

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    readonly property var dayHeaders: firstDayOfWeek === 1
        ? ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        : ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    PopupWindow {
        id: popup
        visible: root.open
        grabFocus: true

        anchor.window: root.anchorWindow
        anchor.rect.x: root.anchorWindow ? root.anchorWindow.width / 2 - popup.implicitWidth / 2 : 0
        anchor.rect.y: root.anchorWindow ? root.anchorWindow.height + 4 : 0

        implicitWidth: 260
        implicitHeight: calendarColumn.implicitHeight + 20
        color: "transparent"

        onVisibleChanged: {
            if (!visible) root.open = false
        }

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

                // Month/year header with navigation
                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "\uf053"  // nf-fa-chevron_left
                        font.family: Theme.fontFam
                        color: Theme.barText
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.viewMonth--
                                if (root.viewMonth < 0) {
                                    root.viewMonth = 11
                                    root.viewYear--
                                }
                            }
                        }
                    }

                    Text {
                        text: monthNames[root.viewMonth] + " " + root.viewYear
                        font.pixelSize: 14
                        font.bold: true
                        color: Theme.barText
                        horizontalAlignment: Text.AlignHCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 60
                    }

                    Text {
                        text: "\uf054"  // nf-fa-chevron_right
                        font.family: Theme.fontFam
                        color: Theme.barText
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.viewMonth++
                                if (root.viewMonth > 11) {
                                    root.viewMonth = 0
                                    root.viewYear++
                                }
                            }
                        }
                    }
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

                    // Empty cells before first day
                    Repeater {
                        model: root.firstDayOffset
                        delegate: Item { width: (parent.width - 12) / 7; height: 24 }
                    }

                    // Day cells
                    Repeater {
                        model: root.daysInMonth

                        delegate: Rectangle {
                            required property int index

                            readonly property int day: index + 1
                            readonly property bool isToday: day === root.today.getDate()
                                                           && root.viewMonth === root.currentMonth
                                                           && root.viewYear === root.currentYear

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

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.open = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    onOpenChanged: {
        if (open) {
            resetView()
        }
    }
}