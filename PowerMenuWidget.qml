import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Power menu button — click to show action grid (Lock, Logout, Suspend, Hibernate, Shutdown, Reboot).
// Matches the BT/network popup style with MDI icons.
Item {
    id: root
    implicitWidth: iconText.implicitWidth + 12

    required property var barWindow
    required property var barContent

    // Compute left edge within barContent for popup anchor
    readonly property real iconLeft: {
        var x = 0;
        var item = root;
        while (item && item !== root.barContent) {
            x += item.x;
            item = item.parent;
        }
        return x;
    }

    property bool menuOpen: false

    // --- Power menu popup ---
    PopupWindow {
        id: menuPopup
        visible: root.menuOpen
        grabFocus: true

        anchor.window: root.barWindow
        anchor.rect.x: root.iconLeft
        anchor.rect.y: root.barWindow.height + 4

        implicitWidth: 240
        implicitHeight: menuGrid.implicitHeight + 20
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: Theme.surface
            border.color: Theme.outlineVar
            border.width: 1

            GridLayout {
                id: menuGrid
                anchors {
                    left: parent.left; leftMargin: Theme.padding.sm
                    top: parent.top; topMargin: Theme.padding.sm
                    right: parent.right; rightMargin: Theme.padding.sm
                    bottom: parent.bottom; bottomMargin: Theme.padding.sm
                }
                columns: 2
                columnSpacing: 6
                rowSpacing: 6

                // --- Lock ---
                PowerAction {
                    iconChar: "󰌾"
                    label: "Lock"
                    command: "loginctl lock-session"
                    onExecuted: root.menuOpen = false
                }

                // --- Logout ---
                PowerAction {
                    iconChar: "󰍃"
                    label: "Logout"
                    command: "~/.config/hypr/scripts/power.sh exit"
                    onExecuted: root.menuOpen = false
                }

                // --- Suspend ---
                PowerAction {
                    iconChar: "󰒲"
                    label: "Suspend"
                    command: "systemctl suspend"
                    onExecuted: root.menuOpen = false
                }

                // --- Hibernate ---
                PowerAction {
                    iconChar: "󰜗"
                    label: "Hibernate"
                    command: "systemctl hibernate"
                    onExecuted: root.menuOpen = false
                }

                // --- Shutdown ---
                PowerAction {
                    iconChar: "󰐥"
                    label: "Shutdown"
                    command: "~/.config/hypr/scripts/power.sh shutdown"
                    onExecuted: root.menuOpen = false
                }

                // --- Reboot ---
                PowerAction {
                    iconChar: "󰜉"
                    label: "Reboot"
                    command: "~/.config/hypr/scripts/power.sh reboot"
                    onExecuted: root.menuOpen = false
                }
            }
        }
    }

    // --- Main icon ---
    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Theme.fontFam
        font.pixelSize: Theme.mdiFontSize
        text: "󰐥"  // md-power
        color: Theme.barText
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.menuOpen = !root.menuOpen
    }
}
