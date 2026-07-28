import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

// Toast popup host — transient notification popups that appear on the right side.
// Clicking a toast opens the Dashboard for full history.
// No bell icon — the clock handles dashboard access.
Item {
    id: root
    implicitWidth: 0
    implicitHeight: 0

    required property var barWindow
    required property var dashRef

    // ── Toast popup (stacked, max 4, animated) ──────────────
    PopupWindow {
        id: toastPopup
        visible: NotificationSingleton.activeToasts.length > 0 && !NotificationSingleton.dndEnabled
        grabFocus: false

        anchor.window: root.barWindow
        anchor.rect.x: Math.max(0, root.barWindow.width - 340)
        anchor.rect.y: root.barWindow.height + 4

        implicitWidth: 320
        implicitHeight: toastList.contentHeight + 12
        color: "transparent"

        ListView {
            id: toastList
            anchors.fill: parent
            spacing: Theme.spacing.sm
            interactive: false
            model: NotificationSingleton.toastAnimModel
            verticalLayoutDirection: ListView.TopToBottom

            add: Transition {
                Anim { property: "opacity"; from: 0; to: 1.0; type: Anim.FastEffects }
                Anim { property: "x"; from: 100; to: 0; type: Anim.Emphasized }
            }

            move: Transition {
                PauseAnimation { duration: 250 }
                Anim { property: "y"; type: Anim.DefaultSpatial }
            }

            delegate: Rectangle {
                required property var modelData

                width: toastList.width
                height: Math.max(40, toastContent.implicitHeight + 14)
                radius: Theme.rounding.sm
                color: toastHover.containsMouse ? Theme.surfBright : Theme.surfCont
                border.color: Theme.outlineVar
                border.width: 1
                clip: true

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
                    id: toastContent
                    anchors {
                        left: parent.left; leftMargin: Theme.padding.sm
                        top: parent.top; topMargin: Theme.spacing.sm
                        right: parent.right; rightMargin: Theme.padding.sm
                    }
                    spacing: Theme.spacing.sm

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: modelData.summary
                            font.pixelSize: 13
                            font.bold: true
                            color: Theme.barText
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.body
                            font.pixelSize: 11
                            color: Theme.textSurf
                            elide: Text.ElideRight
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            maximumLineCount: 2
                            visible: text !== ""
                        }
                    }
                }

                MouseArea {
                    id: toastHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Try default action (open app), then dismiss toast
                        NotificationSingleton.handleDefaultAction(modelData)
                        NotificationSingleton.dismissToast(modelData)
                    }
                }
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────
    function urgencyColor(urgency) {
        if (urgency === NotificationUrgency.Critical) return Theme.error
        if (urgency === NotificationUrgency.Low) return Theme.outline
        return Theme.primary
    }
}