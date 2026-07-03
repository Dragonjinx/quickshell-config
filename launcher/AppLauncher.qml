import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

// Application launcher — replaces rofi -show drun.
// Opens as a FloatingWindow centered on the focused monitor.
//
// Usage from elsewhere:
//   AppLauncher.open()
//   AppLauncher.close()
//   AppLauncher.toggle()
Item {
    id: root

    // Public API
    function open()    { launcherWindow.visible = true; searchField.forceActiveFocus() }
    function close()   { launcherWindow.visible = false }
    function toggle()  { if (launcherWindow.visible) close(); else open() }

    readonly property bool isOpen: launcherWindow.visible

    // Filter string
    property string filter: ""

    // Filtered applications
    readonly property var filteredApps: {
        const f = filter.toLowerCase().trim()
        const all = DesktopEntries.applications
        if (f === "") return all
        return all.filter(app => {
            const name = (app.name ?? "").toLowerCase()
            const generic = (app.genericName ?? "").toLowerCase()
            const keywords = (app.keywords ?? []).join(" ").toLowerCase()
            return name.includes(f) || generic.includes(f) || keywords.includes(f)
        })
    }

    FloatingWindow {
        id: launcherWindow

        visible: false
        focusable: true

        // Center on the focused monitor
        screen: Quickshell.screens.find(s => s.focused) ?? Quickshell.screens[0]
        x: (screen?.width ?? 1920) / 2 - width / 2
        y: (screen?.height ?? 1080) / 3 - height / 2

        implicitWidth: 520
        implicitHeight: clampedHeight
        color: Theme.launcherBackground
        radius: 12

        // Escape to close
        onVisibleChanged: {
            if (visible) {
                searchField.forceActiveFocus()
            }
        }

        readonly property int clampedHeight: Math.min(48 + filteredApps.length * 48 + 24, 600)

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) close()
            if (event.key === Qt.Key_Down)    moveSelection(1)
            if (event.key === Qt.Key_Up)      moveSelection(-1)
            if (event.key === Qt.Key_Return)  activateSelection()
        }

        property int selectedIndex: 0

        function moveSelection(delta) {
            const count = filteredApps.length
            if (count === 0) return
            selectedIndex = (selectedIndex + delta + count) % count
            listView.positionViewAtIndex(selectedIndex, ListView.Contain)
        }

        function activateSelection() {
            const app = filteredApps[selectedIndex]
            if (app) {
                app.execute()
                close()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Search input
            Rectangle {
                id: searchBox
                Layout.fillWidth: true
                implicitHeight: 44
                color: Theme.launcherSurface
                radius: 8

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 14
                    }
                    spacing: 10

                    Text {
                        text: ""  // magnifying glass
                        font.pixelSize: 16
                        color: Theme.launcherDim
                    }

                    TextInput {
                        id: searchField
                        Layout.fillWidth: true
                        font.pixelSize: Theme.launcherFontSize
                        color: Theme.launcherText
                        placeholderText: "Search applications..."
                        placeholderTextColor: Theme.launcherDim
                        clip: true

                        onTextChanged: {
                            root.filter = text
                            launcherWindow.selectedIndex = 0
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) launcherWindow.close()
                            if (event.key === Qt.Key_Down) {
                                launcherWindow.moveSelection(1)
                                event.accepted = true
                            }
                            if (event.key === Qt.Key_Up) {
                                launcherWindow.moveSelection(-1)
                                event.accepted = true
                            }
                            if (event.key === Qt.Key_Return) {
                                launcherWindow.activateSelection()
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            // App list
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(filteredApps.length * 48, 520)
                Layout.topMargin: 8
                Layout.bottomMargin: 8

                model: filteredApps
                clip: true
                currentIndex: launcherWindow.selectedIndex
                boundsBehavior: Flickable.StopAtBounds

                delegate: AppEntry {
                    required property DesktopEntry modelData
                    required property int index

                    width: listView.width
                    entry: modelData
                }
            }
        }
    }

    // Keyboard shortcut listener (Hyprland global shortcut)
    // Using the keybinding via Hyprland is more reliable, but we
    // also offer an in-process shortcut for testing.
    Shortcut {
        sequence: "Meta+Space"
        onActivated: root.toggle()
    }
}