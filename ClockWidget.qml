import QtQuick
import Quickshell

// Clock display — shows 24h time.
// Click: opens the Dashboard (calendar + notification history).
Item {
    id: root
    implicitWidth: timeRow.implicitWidth + 16
    required property var barWindow
    required property var barContent
    required property var dashRef  // reference to Dash popup

    readonly property string displayTime: TimeSingleton.time

    // Accent-forward: clock digits in textBg (primary fg), the ':' separator
    // in primary for a subtle accent pop.
    function timePart(index) {
        const parts = root.displayTime.split(":")
        return parts[index] !== undefined ? parts[index] : ""
    }

    // ── Time text ──
    // Shows 24h time with a primary-colored ':' separator. Click opens Dashboard.
    Row {
        id: timeRow
        anchors.centerIn: parent
        spacing: 1

        Text {
            text: root.timePart(0)
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.barFontSize
            font.bold: true
            color: Theme.textBg
        }
        Text {
            text: ":"
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.barFontSize
            font.bold: true
            color: Theme.primary
        }
        Text {
            text: root.timePart(1)
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.barFontSize
            font.bold: true
            color: Theme.textBg
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