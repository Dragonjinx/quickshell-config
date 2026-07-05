import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Networking

// Main bar — a PanelWindow attached to the top of each screen.
// Uses RowLayout for consistent child sizing.
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

            implicitHeight: 40
            color: "transparent"
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: 40

            Rectangle {
                id: barContent
                anchors.fill: parent
                radius: 10
                color: Theme.barBg

                RowLayout {
                    anchors {
                        fill: parent
                        topMargin: 4
                        bottomMargin: 4
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 0

                    // --- LEFT (minimum 15%, grows with content) ---
                    RowLayout {
                        Layout.fillHeight: true
                        Layout.minimumWidth: parent.width * 0.10
                        spacing: 4

                        Workspaces { Layout.fillHeight: true }
                    }

                    // --- CENTER (fills remaining space) ---
                    WindowTitle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // --- RIGHT (content-driven, no artificial stretching) ---
                    RowLayout {
                        Layout.fillHeight: true
                        spacing: 3

                        VolumeWidget { Layout.fillHeight: true }
                        BluetoothWidget { Layout.fillHeight: true; barWindow: barWindow; barContent: barContent }
                        NetworkWidget { Layout.fillHeight: true; barWindow: barWindow; barContent: barContent }
                        BatteryWidget { Layout.fillHeight: true }
                        ResourceWidget { Layout.fillHeight: true }
                        TrayWidget { Layout.fillHeight: true }
                        PowerMenuWidget { Layout.fillHeight: true }
                        ClockWidget { Layout.fillHeight: true; barWindow: barWindow }
                    }
                }
            }
        }
    }
}