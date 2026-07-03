import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Networking

// Main bar — a PanelWindow attached to the top of each screen.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            margins { top: 6; left: 12; right: 12 }

            exclusiveZone: 36
            implicitHeight: 36
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: Theme.barBg

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 8
                        rightMargin: 8
                    }

                    // --- LEFT ---
                    Row {
                        height: parent.height
                        spacing: 4
                        LauncherButton { id: appMenu }
                        Workspaces {}
                    }

                    Item { Layout.fillWidth: true; height: 1 }

                    // --- CENTER ---
                    WindowTitle {
                        Layout.fillWidth: true
                        height: parent.height
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item { Layout.fillWidth: true; height: 1 }

                    // --- RIGHT ---
                    Row {
                        height: parent.height
                        spacing: 2
                        VolumeWidget {}
                        NetworkWidget {}
                        BluetoothWidget {}
                        BatteryWidget {}
                        TrayWidget {}
                        ClockWidget {}
                    }
                }
            }
        }
    }
}