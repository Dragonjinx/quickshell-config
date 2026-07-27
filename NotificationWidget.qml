import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

// Notification widget — bell icon with badge + toast popup + history panel.
// Replaces swaync notification daemon and control center.
// All data state lives in NotificationSingleton (shared across all bars).
Item {
    id: root
    implicitWidth: iconText.implicitWidth + 12

    required property var barWindow
    required property var barContent

    // Compute left edge within barContent for popup anchor
    readonly property real iconLeft: {
        var x = 0;
        var item = root;
        while (item && item !== root.barContent) {
            x += item.x;
            item = item.parent;
        }
        return x;
    }

    // ── Per-bar UI state ───────────────────────────────────
    property bool historyOpen: false

    // ── Toast popup (top-right, auto-dismiss) ────────────────
    PopupWindow {
        id: toastPopup
        visible: NotificationSingleton.activeToast != null && !NotificationSingleton.dndEnabled
        grabFocus: false

        anchor.window: root.barWindow
        anchor.rect.x: Math.max(0, root.barWindow.width - 340)
        anchor.rect.y: root.barWindow.height + 4

        implicitWidth: 320
        implicitHeight: toastBody.implicitHeight + 20
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: toastBgColor()
            border.color: Theme.outlineVar
            border.width: 1

            // Left urgency bar
            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: 3
                radius: 2
                color: urgencyColor(NotificationSingleton.activeToast?.urgency)
            }

            Column {
                id: toastBody
                anchors {
                    left: parent.left; leftMargin: 14
                    top: parent.top; topMargin: 10
                    right: parent.right; rightMargin: 14
                }
                spacing: 2

                Text {
                    text: NotificationSingleton.activeToast?.summary ?? ""
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.barText
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: NotificationSingleton.activeToast?.body ?? ""
                    font.pixelSize: 12
                    color: Theme.textSurf
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    width: parent.width
                    visible: text !== ""
                    maximumLineCount: 2
                }
            }
        }

        // Click toast to open history
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.historyOpen = true
                NotificationSingleton.dismissToast()
            }
        }
    }

    // ── History / Control Center popup ──────────────────────
    PopupWindow {
        id: historyPopup
        visible: root.historyOpen
        grabFocus: true

        anchor.window: root.barWindow
        anchor.rect.x: Math.max(0, root.iconLeft + iconText.width - 320)
        anchor.rect.y: root.barWindow.height + 4

        implicitWidth: 320
        implicitHeight: Math.min(500, historyColumn.implicitHeight + 60)
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
                    root.historyOpen = false
                    NotificationSingleton.unreadHistory = []
                    NotificationSingleton.unreadCount = 0
                    NotificationSingleton.dismissToast()
                }
            }

            Column {
                id: historyColumn
                anchors {
                    left: parent.left; leftMargin: 12
                    top: parent.top; topMargin: 10
                    right: parent.right; rightMargin: 12
                }
                spacing: 6

                // ── Header ──
                RowLayout {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: "󰂜 Notifications"
                        font.family: Theme.fontFam
                        font.pixelSize: 15
                        font.bold: true
                        color: Theme.barText
                    }

                    Item { Layout.fillWidth: true }

                    // DND toggle
                    Rectangle {
                        Layout.preferredHeight: 28
                        implicitWidth: dndLabel.implicitWidth + 16
                        radius: 6
                        color: dndArea.containsMouse
                            ? (NotificationSingleton.dndEnabled ? Theme.surfCont : Theme.error)
                            : (NotificationSingleton.dndEnabled ? Theme.error : Theme.surfCont)

                        Text {
                            id: dndLabel
                            anchors.centerIn: parent
                            text: NotificationSingleton.dndEnabled ? "󰂛 DND" : "󰂜"
                            font.family: Theme.fontFam
                            font.pixelSize: 12
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
                        Layout.preferredHeight: 28
                        implicitWidth: clearLabel.implicitWidth + 12
                        radius: 6
                        color: clearArea.containsMouse ? Theme.surfCont : "transparent"

                        Text {
                            id: clearLabel
                            anchors.centerIn: parent
                            text: "󰎟"
                            font.family: Theme.fontFam
                            font.pixelSize: 14
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

                // ── Empty state ──
                Text {
                    text: {
                        NotificationSingleton.historyVersion;
                        NotificationSingleton.notificationHistory.length === 0 ? "No notifications" : "";
                    }
                    font.pixelSize: 12
                    color: Theme.textSurf
                    height: 40
                    visible: text !== ""
                }

                // ── Notification list (newest first) ──
                Repeater {
                    model: {
                        // Force QML binding re-evaluation when history changes
                        NotificationSingleton.historyVersion;
                        NotificationSingleton.notificationHistory.slice().reverse();
                    }

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: parent.width
                        height: notifContent.implicitHeight + 14
                        radius: 8
                        color: ma.containsMouse ? Theme.surfCont : "transparent"

                        // Left urgency bar
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
                                left: parent.left; leftMargin: 10
                                top: parent.top; topMargin: 6
                                right: parent.right; rightMargin: 10
                            }
                            spacing: 8

                            // App icon
                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                Layout.alignment: Qt.AlignTop
                                radius: 6
                                color: Theme.surfCont

                                Text {
                                    anchors.centerIn: parent
                                    text: appInitial(modelData.appName)
                                    font.family: Theme.fontFam
                                    font.pixelSize: 14
                                    color: Theme.primary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                // App name + time
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: modelData.appName
                                        font.family: Theme.fontFam
                                        font.pixelSize: 11
                                        color: Theme.outline
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: formatTime(modelData.time)
                                        font.family: Theme.fontFam
                                        font.pixelSize: 11
                                        color: Theme.outline
                                    }
                                }

                                // Summary
                                Text {
                                    text: modelData.summary
                                    font.family: Theme.fontFam
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: Theme.barText
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Body
                                Text {
                                    text: modelData.body
                                    font.family: Theme.fontFam
                                    font.pixelSize: 12
                                    color: Theme.textSurf
                                    elide: Text.ElideRight
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    maximumLineCount: 2
                                    visible: text !== ""
                                }

                                // Action buttons
                                Row {
                                    spacing: 6
                                    visible: modelData.actions && modelData.actions.length > 0

                                    Repeater {
                                        model: modelData.actions

                                        delegate: Rectangle {
                                            required property var modelData
                                            property var actionRef: modelData

                                            height: 24
                                            implicitWidth: actionLabel.implicitWidth + 12
                                            radius: 4
                                            color: actionArea.containsMouse ? Theme.primary : "transparent"
                                            border.color: Theme.outlineVar
                                            border.width: 1

                                            Text {
                                                id: actionLabel
                                                anchors.centerIn: parent
                                                text: actionRef.text
                                                font.family: Theme.fontFam
                                                font.pixelSize: 11
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
                }
            }
        }
    }

    // ── Bar Icon ──────────────────────────────────────────
    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Theme.fontFam
        font.pixelSize: Theme.mdiFontSize
        text: NotificationSingleton.dndEnabled ? "󰂛" : (NotificationSingleton.unreadCount > 0 ? "󰵙" : "󰂜")
        color: NotificationSingleton.dndEnabled ? Theme.error : (NotificationSingleton.unreadCount > 0 ? Theme.primary : Theme.barText)
    }

    // Unread badge
    Rectangle {
        anchors {
            top: iconText.top; topMargin: -4
            right: iconText.right; rightMargin: -6
        }
        width: 16
        height: 16
        radius: 8
        color: Theme.error
        visible: NotificationSingleton.unreadCount > 0 && !NotificationSingleton.dndEnabled

        Text {
            anchors.centerIn: parent
            text: NotificationSingleton.unreadCount > 99 ? "!" : NotificationSingleton.unreadCount
            font.family: Theme.fontFam
            font.pixelSize: 9
            font.bold: true
            color: Theme.onPrim  // was onError, use onPrim as fallback
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.historyOpen = !root.historyOpen
            if (root.historyOpen) {
                NotificationSingleton.unreadHistory = []
                NotificationSingleton.unreadCount = 0
                NotificationSingleton.dismissToast()
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────
    function urgencyColor(urgency) {
        if (urgency === NotificationUrgency.Critical) return Theme.error
        if (urgency === NotificationUrgency.Low) return Theme.outline
        return Theme.primary
    }

    function toastBgColor() {
        var u = NotificationSingleton.activeToast?.urgency
        if (u === NotificationUrgency.Low) return Theme.surface
        return Theme.surfCont
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
