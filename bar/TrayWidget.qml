import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu

// System tray using the StatusNotifierItem protocol.
Item {
    id: root

    implicitWidth: trayRow.implicitWidth + 12
    height: parent?.implicitHeight ?? 30

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property SystemTrayItem modelData

                implicitWidth: icon.implicitWidth + 4
                implicitHeight: root.height

                IconImage {
                    id: icon
                    anchors.centerIn: parent
                    implicitSize: 18
                    source: modelData.icon ?? ""
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