import QtQuick
import Quickshell

// Battery widget — Nerd Font battery icons, hidden if no battery found.
// Click: toggles between percentage and estimated time remaining.
Item {
    id: root
    implicitWidth: contentRow.implicitWidth + 12
    visible: BatterySingleton.percentage >= 0

    property bool showTime: false

    // 5-level color gradient matching the 5 distinct battery icons.
    // As charge drops: green -> yellow -> peach -> maroon -> red.
    // (success=green, yellow, amber=peach, maroon, error=red).
    readonly property color batteryColor: {
        const p = BatterySingleton.percentage
        if (BatterySingleton.charging) return Theme.success
        if (p >= 90) return Theme.batFull      // battery_4
        if (p >= 65) return Theme.batHigh      // battery_3
        if (p >= 40) return Theme.batMid       // battery_2
        if (p >= 15) return Theme.batLow       // battery_1
        return Theme.batCrit                   // battery_0 (critical)
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            font.pixelSize: Theme.barFontSize
            text: BatterySingleton.iconNerd
            color: root.batteryColor
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.showTime ? BatterySingleton.timeRemainingText : BatterySingleton.displayText
            font.pixelSize: Theme.barFontSize
            color: root.batteryColor
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.showTime = !root.showTime
    }
}