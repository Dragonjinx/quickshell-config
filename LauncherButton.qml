import QtQuick
import Quickshell

// Button to open the application launcher (replaces rofi -show drun).
// Clicking launches a FloatingWindow with the app launcher.
Item {
    id: root

    implicitWidth: label.implicitWidth + 20

    property bool launcherOpen: false

    Text {
        id: label
        anchors.centerIn: parent
        text: "Apps"
        font.pixelSize: Theme.barFontSize
        font.bold: true
        color: Theme.barText
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: root.opacity = 0.7
        onExited: root.opacity = 1.0
        onClicked: {
            root.launcherOpen = !root.launcherOpen
            if (root.launcherOpen) {
                // Signal the launcher to open
                AppLauncher.open()
            } else {
                AppLauncher.close()
            }
        }
    }
}