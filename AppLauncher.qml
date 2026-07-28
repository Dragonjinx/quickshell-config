import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

// Application launcher — replaces rofi -show drun.
// Opens as a FloatingWindow centered on the focused monitor.
Item {
    id: root

    function open()    { launcherWindow.visible = true; searchField.forceActiveFocus() }
    function close()   { launcherWindow.visible = false }
    function toggle()  { if (launcherWindow.visible) close(); else open() }

    readonly property bool isOpen: launcherWindow.visible
    property string filter: ""

    function launchApp(entry) {
        var cmd = entry.command.slice()
        if (entry.runInTerminal) {
            cmd = ["alacritty", "-e"].concat(cmd)
        }
        Quickshell.execDetached(["uwsm-app", "--"].concat(cmd))
    }

    readonly property var allApps: {
        var src = DesktopEntries.applications.values
        var n = typeof src.length !== "undefined" ? src.length : 0
        var apps = []
        for (var i = 0; i < n; ++i) apps.push(src[i])
        apps.sort(function(a, b) {
            var nameA = (a.name || "").toLowerCase()
            var nameB = (b.name || "").toLowerCase()
            if (nameA < nameB) return -1
            if (nameA > nameB) return 1
            return 0
        })
        return apps
    }
    readonly property var filteredApps: root._filter(root.allApps, root.filter)

    function _filter(apps, f) {
        var trimmed = f.toLowerCase().trim()
        if (trimmed === "") return apps
        return apps.filter(function(app) {
            var name = (app.name || "").toLowerCase()
            var generic = (app.genericName || "").toLowerCase()
            var keywords = (app.keywords || []).join(" ").toLowerCase()
            return name.indexOf(trimmed) !== -1
                || generic.indexOf(trimmed) !== -1
                || keywords.indexOf(trimmed) !== -1
        })
    }

    FloatingWindow {
        id: launcherWindow
        visible: false
        title: "quickshell-app-launcher"

        screen: Quickshell.screens[0]

        readonly property var centerScreen: {
            var idx = 0
            for (var i = 0; i < Quickshell.screens.length; ++i) {
                if (Quickshell.screens[i].focused) { idx = i; break }
            }
            return Quickshell.screens[idx]
        }

        Component.onCompleted: recalcPosition()
        onVisibleChanged: {
            if (visible) {
                searchField.text = ""
                launcherWindow.selectedIndex = 0
                listView.positionViewAtIndex(0, ListView.Contain)
                searchField.forceActiveFocus()
                recalcPosition()
            }
        }

        function recalcPosition() {
            var s = centerScreen
            if (s) {
                x = (s.width - width) / 2
                y = Math.max(10, (s.height - height) / 3)
            }
        }

        implicitWidth: Math.min(520, centerScreen ? centerScreen.width * 0.5 : 520)
        implicitHeight: Math.min(600, centerScreen ? centerScreen.height * 0.75 : 600)
        color: "transparent"

        property int selectedIndex: 0

        function moveSelection(delta) {
            var apps = root.filteredApps
            var count = apps.length
            if (count === 0) return
            selectedIndex = (selectedIndex + delta + count) % count
            listView.positionViewAtIndex(selectedIndex, ListView.Contain)
        }

        function activateSelection() {
            var apps = root.filteredApps
            var app = apps[launcherWindow.selectedIndex]
            if (app) { root.launchApp(app); close() }
        }

        Item {
            anchors.fill: parent
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) close()
                if (event.key === Qt.Key_Down)    moveSelection(1)
                if (event.key === Qt.Key_Up)      moveSelection(-1)
                if (event.key === Qt.Key_Return)  activateSelection()
            }

            Rectangle {
            anchors.fill: parent
            radius: Theme.rounding.md
            color: Theme.launchBg

            Column {
                id: layoutColumn
                anchors.fill: parent
                spacing: 0
                topPadding: 0
                bottomPadding: Theme.spacing.sm

                Rectangle {
                    id: searchBox
                    width: parent.width
                    height: 44
                    color: Theme.launchSurface
                    radius: Theme.rounding.zero

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: Theme.padding.md
                            rightMargin: Theme.padding.md
                        }
                        spacing: Theme.padding.sm

                        Text {
                            text: "󰍉"
                            font.pixelSize: Theme.launchFontSize
                            color: Theme.launchDim
                        }

                        TextInput {
                            id: searchField
                            Layout.fillWidth: true
                            font.pixelSize: Theme.launchFontSize
                            color: Theme.launchText
                            clip: true

                            onTextChanged: {
                                root.filter = text
                                launcherWindow.selectedIndex = 0
                            }

                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Escape) root.close()
                                if (event.key === Qt.Key_Down) {
                                    launcherWindow.moveSelection(1); event.accepted = true
                                }
                                if (event.key === Qt.Key_Up) {
                                    launcherWindow.moveSelection(-1); event.accepted = true
                                }
                                if (event.key === Qt.Key_Return) {
                                    launcherWindow.activateSelection(); event.accepted = true
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: listView
                    width: parent.width
                    height: Math.min(root.filteredApps.length * 48, 520)
                    topMargin: Theme.padding.sm
                    bottomMargin: Theme.padding.xs
                    model: filteredApps
                    clip: true
                    currentIndex: launcherWindow.selectedIndex
                    boundsBehavior: Flickable.StopAtBounds
                    highlightMoveDuration: 0
                    highlightFollowsCurrentItem: true

                    delegate: AppEntry {
                        required property DesktopEntry modelData
                        required property int index
                        width: listView.width
                        entry: modelData
                        selected: index === listView.currentIndex
                        launchAppCallback: root.launchApp
                        onActivated: root.close()
                    }
                }
            }
        }
    }
    }

    // Triggered via Hyprland global shortcut (see shell.qml for details).
}