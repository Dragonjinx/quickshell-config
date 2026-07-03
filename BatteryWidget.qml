import QtQuick
import Quickshell

// Battery widget — Nerd Font battery icons, hidden if no battery found.
Item {
    id: root
    implicitWidth: 55
    visible: BatterySingleton.percentage >= 0

    readonly property string iconNerd: BatterySingleton.pluggedIn ? "\uf1e6" :           // nf-fa-plug
                                        BatterySingleton.charging ? "\uf0e7" :            // nf-fa-bolt
                                        BatterySingleton.percentage < 15 ? "\uf244" :     // nf-fa-battery_0
                                        BatterySingleton.percentage < 40 ? "\uf243" :     // nf-fa-battery_1
                                        BatterySingleton.percentage < 65 ? "\uf242" :     // nf-fa-battery_2
                                        BatterySingleton.percentage < 90 ? "\uf241" :     // nf-fa-battery_3
                                                                           "\uf240"        // nf-fa-battery_4

    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: root.iconNerd
            color: BatterySingleton.percentage < 15 ? Theme.error : Theme.barText
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: BatterySingleton.displayText
            font.pixelSize: Theme.barFontSize
            color: BatterySingleton.percentage < 15 ? Theme.error : Theme.barText
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["alacritty", "-e", "btop"])
        }
    }
}