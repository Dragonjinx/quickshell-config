import QtQuick
import Quickshell

// Clock display — shows 24h time.
// Click: opens the Dashboard (calendar + notification history).
Item {
    id: root
    implicitWidth: displayText.contentWidth + 16
    required property var barWindow
    required property var barContent
    required property var dashRef  // reference to Dash popup

    readonly property string displayTime: TimeSingleton.time

    // ── Time text ──
    // Shows 24h time. Click opens Dashboard.
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

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: dashRef.toggle()
    }
}