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

    // Shared open state — toggled by ClockWidget or ToastHost
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
                margins: Theme.padding.md
            }
            spacing: Theme.spacing.sm

            // ── Calendar ────────────────────────────────────
            Column {
                width: parent.width
                spacing: Theme.spacing.sm

                // Date header: bold day name + DD.MM.YYYY (right-aligned)
                RowLayout {
                    width: parent.width
                    spacing: Theme.spacing.sm

                    Item { Layout.fillWidth: true }

                    Text {
                        text: displayDay
                        font.pixelSize: 16
                        font.bold: true
                        color: Theme.barText
                    }

                    Text {
                        text: "·"
                        font.pixelSize: 16
                        color: Theme.outline
                    }

                    Text {
                        text: displayDate
                        font.pixelSize: 16
                        color: Theme.barText
                    }
                }

                // Separator between date header and calendar
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.outlineVar
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
                spacing: Theme.spacing.sm

                // Header row: [Clear | spacer | icon+text | DND]
                RowLayout {
                    width: parent.width
                    spacing: Theme.spacing.sm

                    // Clear all (left)
                    Rectangle {
                        Layout.preferredHeight: 26
                        implicitWidth: clearLabel.implicitWidth + Theme.padding.sm
                        radius: Theme.rounding.xs
                        color: clearArea.containsMouse ? Theme.surfCont : "transparent"

                        Text {
                            id: clearLabel
                            anchors.centerIn: parent
                            text: "✕"
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

                    Item { Layout.fillWidth: true }

                    // Notifications title
                    Text {
                        text: "Notifications"
                        font.family: Theme.fontFam
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.barText
                    }

                    // DND toggle (right)
                    Rectangle {
                        Layout.preferredHeight: 26
                        implicitWidth: dndLabel.implicitWidth + 14
                        radius: Theme.rounding.xs
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
                }

                // ── Separator ──
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.outlineVar
                }

                // ── Notification list (ListView with remove + drag-dismiss animations) ──
                ListView {
                    id: notifList
                    width: parent.width
                    height: Math.min(380, notifList.contentHeight)
                    clip: true
                    interactive: true
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    model: {
                        NotificationSingleton.historyVersion;
                        NotificationSingleton.notificationHistory.slice().reverse();
                    }

                    delegate: NotifDelegate {
                        listView: notifList
                    }

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

                    // Empty state
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
    // Features: click-to-expand, swipe-to-dismiss, urgency bar, action buttons
    component NotifDelegate: Rectangle {
        required property var modelData
        required property ListView listView

        // Expand/collapse state
        property bool expanded: false

        // Invoke an action from the notification's action list by identifier.
        // Uses the retained Notification QObject from NotificationSingleton.
        function _invokeAction(actionIdentifier) {
            NotificationSingleton.invokeAction(modelData.id, actionIdentifier)
        }

        width: listView.width
        height: expanded
            ? notifContent.implicitHeight + Theme.spacing.md
            : Math.min(notifContent.implicitHeight + Theme.spacing.md, 72)
        radius: Theme.rounding.xs
        color: ma.containsMouse ? Theme.surfCont : "transparent"
        clip: true

        Behavior on height {
            Anim { type: Anim.FastSpatial }
        }

        // ── Drag-to-dismiss ──
        property real dragStartX: 0
        property real dragOffset: 0

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
                left: parent.left; leftMargin: Theme.spacing.sm
                top: parent.top; topMargin: Theme.spacing.sm
                right: parent.right; rightMargin: Theme.spacing.sm
            }
            spacing: Theme.spacing.sm

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

                // App name + time + expand indicator
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
                        text: expanded ? "▲" : "▼"
                        font.pixelSize: 8
                        color: Theme.outline
                        visible: hasExpandableContent()
                    }

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
                    maximumLineCount: expanded ? -1 : 1
                }

                // Body (only shown when expanded or short enough)
                Text {
                    text: modelData.body
                    font.family: Theme.fontFam
                    font.pixelSize: 11
                    color: Theme.textSurf
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    maximumLineCount: expanded ? -1 : 0
                    visible: expanded || (modelData.body && modelData.body.length < 80)
                }

                // Action buttons (only when expanded)
                Row {
                    spacing: 4
                    visible: expanded && modelData.actions && modelData.actions.length > 0

                    Repeater {
                        model: modelData.actions

                        delegate: Rectangle {
                            required property var modelData

                            height: 22
                            implicitWidth: actionLabel.implicitWidth + 10
                            radius: 4
                            color: actionArea.containsMouse ? Theme.primary : "transparent"
                            border.color: Theme.outlineVar
                            border.width: 1

                            Text {
                                id: actionLabel
                                anchors.centerIn: parent
                                text: modelData.text
                                font.family: Theme.fontFam
                                font.pixelSize: 10
                                color: actionArea.containsMouse ? Theme.onPrim : Theme.primary
                            }

                            MouseArea {
                                id: actionArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: _invokeAction(modelData.identifier)
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
            drag.target: parent
            drag.axis: Drag.XAxis

            onPressed: event => {
                parent.dragStartX = event.x
            }

            onPositionChanged: event => {
                parent.dragOffset = event.x - parent.dragStartX
                if (pressed && Math.abs(parent.dragOffset) > 0)
                    parent.x = parent.dragOffset
            }

            onReleased: event => {
                if (Math.abs(parent.dragOffset) > parent.width * 0.35) {
                    // Dismiss
                    NotificationSingleton.dismissNotification(modelData)
                } else if (Math.abs(parent.dragOffset) > 0) {
                    // Snap back
                    parent.x = 0
                } else {
                    // Click: try default action (open app) first
                    if (!NotificationSingleton.handleDefaultAction(modelData)) {
                        // No default action or desktop entry — fall back to expand/mark read
                        if (!hasExpandableContent()) {
                            NotificationSingleton.markRead(modelData)
                        } else {
                            parent.expanded = !parent.expanded
                            NotificationSingleton.markRead(modelData)
                        }
                    } else {
                        // Default action handled, still mark as read
                        NotificationSingleton.markRead(modelData)
                    }
                }
                parent.dragOffset = 0
            }

            // Snap-back animation
            Behavior on x {
                Anim { type: Anim.FastSpatial }
            }
        }

        // Check if this notification has expandable content (body > 1 line or has actions)
        function hasExpandableContent() {
            if (modelData.actions && modelData.actions.length > 0) return true
            if (modelData.body && modelData.body.length > 80) return true
            return false
        }
    }

    // ── Calendar helpers ──────────────────────────────────
    readonly property date today: new Date()
    readonly property int currentMonth: today.getMonth()
    readonly property int currentYear: today.getFullYear()
    readonly property int firstDayOfWeek: 1  // Monday

    readonly property string displayDate: Qt.formatDateTime(today, "dd.MM.yyyy")
    readonly property string displayDay: Qt.formatDateTime(today, "dddd")

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