import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Networking

// Main bar — a PanelWindow attached to the top of each screen.
// Mimics the layout of your current Waybar.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow

            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 6
                left: 12
                right: 12
            }

            exclusiveZone: 36
            implicitHeight: 36
            color: Theme.barBackground
            radius: 10

            // Main horizontal layout
            Row {
                anchors {
                    fill: parent
                    leftMargin: 8
                    rightMargin: 8
                }

                spacing: 0

                // --- LEFT section ---
                Row {
                    height: parent.height
                    spacing: 4

                    LauncherButton { id: appMenu }
                    Workspaces {}
                }

                // Spacer
                Item { Layout.fillWidth: true; height: 1 }

                // --- CENTER section ---
                WindowTitle {
                    Layout.fillWidth: true
                    height: parent.height
                    horizontalAlignment: Text.AlignHCenter
                }

                // Spacer
                Item { Layout.fillWidth: true; height: 1 }

                // --- RIGHT section ---
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