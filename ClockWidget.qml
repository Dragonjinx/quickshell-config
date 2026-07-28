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

    // ── Time text ──
    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: displayText
            anchors.verticalCenter: parent.verticalCenter
            text: root.displayTime
            font.pixelSize: Theme.barFontSize
            font.bold: true
            color: Theme.barText
        }
    }

    // ── Hover tooltip: shows date ──
    Rectangle {
        id: dateTooltip
        visible: mouseArea.containsMouse && !dashRef.dashOpen
        anchors {
            top: parent.bottom; topMargin: 4
            horizontalCenter: parent.horizontalCenter
        }
        implicitWidth: tooltipText.implicitWidth + 12
        height: 22
        radius: 4
        color: Theme.surface
        border.color: Theme.outlineVar

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: root.displayDate
            font.pixelSize: 11
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