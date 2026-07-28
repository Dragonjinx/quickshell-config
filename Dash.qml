import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications

// Dashboard — vertical stack of calendar + notification history in one popup.
// Opens when the clock or notification bell is clicked.
// Toast popups remain independent.
PopupWindow {
    id: root
    visible: dashOpen
    grabFocus: true

    // Shared open state — toggled by ClockWidget or NotificationWidget
    property bool dashOpen: false
    onDashOpenChanged: {
        if (dashOpen) {
            NotificationSingleton.unreadHistory = []
            NotificationSingleton.unreadCount = 0
            NotificationSingleton.dismissAllToasts()
        }
    }

    function toggle() {
        dashOpen = !dashOpen
    }

    required property var anchorWindow
    required property var barContent

    // Anchor right edge ~12px from bar window right edge (near clock/bell)
    anchor.window: anchorWindow
    anchor.rect.x: anchorWindow.width - implicitWidth - 5
    anchor.rect.y: anchorWindow.height + 4

    implicitWidth: 340
    implicitHeight: Math.min(640, dashColumn.implicitHeight + 24)
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.surface
        border.color: Theme.outlineVar
        border.width: 1
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.dashOpen = false
            }
        }

        Column {
            id: dashColumn
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 10

            // ── Calendar ────────────────────────────────────
            Column {
                width: parent.width
                spacing: 6

                Text {
                    width: parent.width
                    text: monthNames[currentMonth] + " " + currentYear
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.barText
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    width: parent.width
                    spacing: 2
                    Repeater {
                        model: dayHeaders
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

                Grid {
                    columns: 7
                    columnSpacing: 2
                    rowSpacing: 2
                    width: parent.width

                    Repeater {
                        model: firstDayOffset
                        delegate: Item { width: (parent.width - 12) / 7; height: 24 }
                    }

                    Repeater {
                        model: daysInMonth
                        delegate: Rectangle {
                            required property int index
                            readonly property int day: index + 1
                            readonly property bool isToday: day === today.getDate()

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

            // ── Separator ──
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outlineVar
            }

            // ── Notifications ───────────────────────────────
            Column {
                width: parent.width
                spacing: 6

                // Header row
                RowLayout {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "󰂜 Notifications"
                        font.family: Theme.fontFam
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.barText
                    }

                    Item { Layout.fillWidth: true }

                    // DND toggle
                    Rectangle {
                        Layout.preferredHeight: 26
                        implicitWidth: dndLabel.implicitWidth + 14
                        radius: 5
                        color: dndArea.containsMouse
                            ? (NotificationSingleton.dndEnabled ? Theme.surfCont : Theme.error)
                            : (NotificationSingleton.dndEnabled ? Theme.error : Theme.surfCont)

                        Text {
                            id: dndLabel
                            anchors.centerIn: parent
                            text: NotificationSingleton.dndEnabled ? "󰂛 DND" : "󰂜"
                            font.family: Theme.fontFam
                            font.pixelSize: 11
                            color: NotificationSingleton.dndEnabled ? Theme.onPrim : Theme.barText
                        }

                        MouseArea {
                            id: dndArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationSingleton.dndEnabled = !NotificationSingleton.dndEnabled
                        }
                    }

                    // Clear all
                    Rectangle {
                        Layout.preferredHeight: 26
                        implicitWidth: clearLabel.implicitWidth + 10
                        radius: 5
                        color: clearArea.containsMouse ? Theme.surfCont : "transparent"

                        Text {
                            id: clearLabel
                            anchors.centerIn: parent
                            text: "󰎟"
                            font.family: Theme.fontFam
                            font.pixelSize: 13
                            color: Theme.textSurf
                        }

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationSingleton.clearAll()
                        }
                    }
                }

                // ── Separator ──
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.outlineVar
                }

                // ── Notification list (ListView with remove animations, following caelestia pattern) ──
                ListView {
                    id: notifList
                    width: parent.width
                    height: Math.min(380, notifList.contentHeight)
                    contentHeight: notifCol.implicitHeight
                    clip: true
                    interactive: true
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    model: {
                        NotificationSingleton.historyVersion;
                        NotificationSingleton.notificationHistory.slice().reverse();
                    }

                    delegate: NotifDelegate {}

                    // When items are removed (dismiss/clear), animate them sliding out
                    remove: Transition {
                        SequentialAnimation {
                            PropertyAction {
                                target: notifList
                                property: "interactive"
                                value: false
                            }
                            Anim {
                                property: "opacity"
                                from: 1.0; to: 0
                                type: Anim.FastEffects
                            }
                            Anim {
                                property: "x"
                                from: 0; to: parent ? parent.width : 340
                                type: Anim.Emphasized
                            }
                            PropertyAction {
                                target: notifList
                                property: "interactive"
                                value: true
                            }
                        }
                    }

                    // Remaining items slide up smoothly
                    move: Transition {
                        Anim {
                            property: "y"
                            type: Anim.DefaultSpatial
                        }
                    }

                    // Empty state overlay — shown via a Loader when count is 0
                    Loader {
                        anchors.centerIn: parent
                        active: notifList.count === 0 && notifList.height > 40
                        visible: active

                        sourceComponent: Text {
                            text: "No notifications"
                            font.pixelSize: 12
                            color: Theme.textSurf
                            height: 40
                        }
                    }
                }
            }
        }
    }

    // ── Notification delegate component ──
    component NotifDelegate: Rectangle {
        required property var modelData

        width: notifList.width
        height: notifContent.implicitHeight + 12
        radius: 6
        color: ma.containsMouse ? Theme.surfCont : "transparent"

        // Urgency bar
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: 3
            radius: 2
            color: urgencyColor(modelData.urgency)
        }

        RowLayout {
            id: notifContent
            anchors {
                left: parent.left; leftMargin: 8
                top: parent.top; topMargin: 5
                right: parent.right; rightMargin: 8
            }
            spacing: 6

            // App icon
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop
                radius: 5
                color: Theme.surfCont

                Text {
                    anchors.centerIn: parent
                    text: appInitial(modelData.appName)
                    font.family: Theme.fontFam
                    font.pixelSize: 12
                    color: Theme.primary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                // App name + time
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: modelData.appName
                        font.family: Theme.fontFam
                        font.pixelSize: 10
                        color: Theme.outline
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: formatTime(modelData.time)
                        font.family: Theme.fontFam
                        font.pixelSize: 10
                        color: Theme.outline
                    }
                }

                // Summary
                Text {
                    text: modelData.summary
                    font.family: Theme.fontFam
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.barText
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Body
                Text {
                    text: modelData.body
                    font.family: Theme.fontFam
                    font.pixelSize: 11
                    color: Theme.textSurf
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    maximumLineCount: 2
                    visible: text !== ""
                }

                // Action buttons
                Row {
                    spacing: 4
                    visible: modelData.actions && modelData.actions.length > 0

                    Repeater {
                        model: modelData.actions

                        delegate: Rectangle {
                            required property var modelData
                            property var actionRef: modelData

                            height: 22
                            implicitWidth: actionLabel.implicitWidth + 10
                            radius: 4
                            color: actionArea.containsMouse ? Theme.primary : "transparent"
                            border.color: Theme.outlineVar
                            border.width: 1

                            Text {
                                id: actionLabel
                                anchors.centerIn: parent
                                text: actionRef.text
                                font.family: Theme.fontFam
                                font.pixelSize: 10
                                color: actionArea.containsMouse ? Theme.onPrim : Theme.primary
                            }

                            MouseArea {
                                id: actionArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: actionRef.invoke()
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: NotificationSingleton.markRead(modelData)
        }
    }

    // ── Calendar helpers ──────────────────────────────────
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

    // ── Notification helpers ──────────────────────────────
    function urgencyColor(urgency) {
        if (urgency === NotificationUrgency.Critical) return Theme.error
        if (urgency === NotificationUrgency.Low) return Theme.outline
        return Theme.primary
    }

    function appInitial(name) {
        if (!name || name.length === 0) return "?"
        return name.charAt(0).toUpperCase()
    }

    function formatTime(date) {
        if (!date) return ""
        var h = date.getHours().toString().padStart(2, "0")
        var m = date.getMinutes().toString().padStart(2, "0")
        return h + ":" + m
    }
}