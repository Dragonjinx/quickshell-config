import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu

// System tray using the StatusNotifierItem protocol.
Item {
    id: root

    implicitWidth: Math.max(trayRow.implicitWidth + 16, 40)

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property SystemTrayItem modelData

                implicitWidth: icon.implicitWidth + 2
                implicitHeight: root.height

                IconImage {
                    id: icon
                    anchors.centerIn: parent
                    implicitSize: 16
                    source: modelData.icon || ""
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            modelData.activate()
                        } else {
                            modelData.contextMenu()
                        }
                    }
                }
            }
        }
    }
}