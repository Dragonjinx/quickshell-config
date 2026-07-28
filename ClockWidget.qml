import QtQuick
import Quickshell

// Clock display — shows 24h time by default.
// Click: opens the Dashboard (calendar + notification history).
// Hover: shows current date (DD-MM-YYYY) as a tooltip below.
Item {
    id: root
    implicitWidth: displayText.contentWidth + 16
    required property var barWindow
    required property var barContent
    required property var dashRef  // reference to Dash popup

    readonly property string displayTime: TimeSingleton.time
    readonly property string displayDate: Qt.formatDateTime(new Date(), "dd.MM.yyyy")

    // ── Time / date text ──
    // Default: shows time. Hover: shows date (DD-MM-YYYY).
    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: displayText
            anchors.verticalCenter: parent.verticalCenter
            text: mouseArea.containsMouse ? root.displayDate : root.displayTime
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
        onClicked: dashRef.toggle()
    }
}