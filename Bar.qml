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

            implicitHeight: 36
            color: "transparent"
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: 36

            Rectangle {
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

                    // --- LEFT (15%) ---
                    RowLayout {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.15
                        spacing: 4

                        Workspaces { Layout.fillHeight: true }
                    }

                    // --- CENTER (60%) ---
                    WindowTitle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.60
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // --- RIGHT (25%) ---
                    RowLayout {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.25
                        spacing: 6

                        VolumeWidget { Layout.fillHeight: true }
                        BluetoothWidget { Layout.fillHeight: true }
                        NetworkWidget { Layout.fillHeight: true; barWindow: barWindow }
                        BatteryWidget { Layout.fillHeight: true }
                        TrayWidget { Layout.fillHeight: true }
                        PowerMenuWidget { Layout.fillHeight: true }
                        ClockWidget { Layout.fillHeight: true; barWindow: barWindow }
                    }
                }
            }
        }
    }
}