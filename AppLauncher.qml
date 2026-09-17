import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
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
            cmd = ["kitty", "-e"].concat(cmd)
        }
        Quickshell.execDetached(["uwsm-app", "--"].concat(cmd))
    }

    property var allApps: _sortApps(DesktopEntries.applications.values)

    function _sortApps(values) {
        var n = typeof values.length !== "undefined" ? values.length : 0
        var apps = []
        for (var i = 0; i < n; ++i) apps.push(values[i])
        apps.sort(function(a, b) {
            var nameA = (a.name || "").toLowerCase()
            var nameB = (b.name || "").toLowerCase()
            if (nameA < nameB) return -1
            if (nameA > nameB) return 1
            return 0
        })
        return apps
    }
    property var filteredApps: root._filter(root.allApps, root.filter)

    // ── Alias mode (":" prefix) ─────────────────────────────
    // Typing ":" switches the launcher to bash alias/function search. The list
    // is dumped once at startup from the interactive rc by
    // scripts/qs-alias-dump.sh (PATH-stubbed — side-effect free, ~0.1s).
    // Enter executes the selection via scripts/qs-alias-run.sh, which pops a
    // swaync notification with the result or the exit code + error tail.
    readonly property bool aliasMode: root.filter.startsWith(":")
    // Repo lives at a fixed path (quickshell is run with -c ~/Repos/quickshell-config).
    readonly property string qsScriptsDir: "/home/abhilekh/Repos/quickshell-config/scripts"

    property var aliases: []
    property bool aliasesLoaded: false
    // QtQuick var arrays don't auto-notify on push — version counter forces the
    // filteredAliases binding to recompute as dump lines stream in (same pattern
    // as Dash.qml's historyVersion).
    property int aliasVersion: 0

    Process {
        id: aliasDump
        command: [root.qsScriptsDir + "/qs-alias-dump.sh"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                var t = line.trim()
                if (t.length === 0) return
                var fields = t.split("\t")
                if (fields.length < 1 || fields[0].length === 0) return
                root.aliases.push({
                    name: fields[0],
                    definition: fields.length > 1 ? fields.slice(1).join("\t") : ""
                })
                root.aliasVersion++
            }
        }

        onExited: function(code, status) {
            root.aliasesLoaded = true
        }
    }

    property var filteredAliases: {
        root.aliasVersion;  // recompute as dump lines arrive
        root.aliasMode;
        return root.aliasMode ? root._filterAliases(root.aliases, root.filter.slice(1)) : []
    }

    function _filterAliases(aliases, f) {
        var q = f.toLowerCase().trim()
        if (q === "") return aliases
        var scored = []
        for (var i = 0; i < aliases.length; ++i) {
            var a = aliases[i]
            var name = (a.name || "").toLowerCase()
            var def = (a.definition || "").toLowerCase()
            var score = -1
            if (name === q) score = 0
            else if (name.startsWith(q)) score = 1
            else if (name.indexOf(q) !== -1) score = 10 + name.indexOf(q)
            else if (def.indexOf(q) !== -1) score = 100 + def.indexOf(q)
            if (score >= 0) scored.push({ entry: a, score: score, lname: name })
        }
        scored.sort(root._compareScored)
        var sorted = []
        for (var j = 0; j < scored.length; ++j) sorted.push(scored[j].entry)
        return sorted
    }

    function runAlias(name) {
        Quickshell.execDetached([root.qsScriptsDir + "/qs-alias-run.sh", name])
    }

    // Ranking: exact name > name prefix > name substring (earlier occurrence = better)
    // > generic name > keywords; alphabetical within equal scores.
    function _compareScored(a, b) {
        if (a.score !== b.score) return a.score - b.score
        if (a.lname < b.lname) return -1
        if (a.lname > b.lname) return 1
        return 0
    }

    function _filter(apps, f) {
        var q = f.toLowerCase().trim()
        if (q === "") return apps
        var scored = []
        for (var i = 0; i < apps.length; ++i) {
            var app = apps[i]
            var name = (app.name || "").toLowerCase()
            var generic = (app.genericName || "").toLowerCase()
            var keywords = (app.keywords || []).join(" ").toLowerCase()
            var score = -1
            if (name === q) score = 0
            else if (name.startsWith(q)) score = 1
            else if (name.indexOf(q) !== -1) score = 10 + name.indexOf(q)
            else if (generic.startsWith(q)) score = 50
            else if (generic.indexOf(q) !== -1) score = 60 + generic.indexOf(q)
            else if (keywords.indexOf(q) !== -1) score = 100 + keywords.indexOf(q)
            if (score >= 0) scored.push({ entry: app, score: score, lname: name })
        }
        scored.sort(root._compareScored)
        var sorted = []
        for (var j = 0; j < scored.length; ++j) sorted.push(scored[j].entry)
        return sorted
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
                if (!root.aliasesLoaded) { root.aliases = []; aliasDump.running = true }
                searchField.text = ""
                launcherWindow.selectedIndex = 0
                appList.positionViewAtIndex(0, ListView.Contain)
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

        readonly property var currentList: root.aliasMode ? root.filteredAliases : root.filteredApps

        function moveSelection(delta) {
            var entries = launcherWindow.currentList
            var count = entries.length
            if (count === 0) return
            selectedIndex = (selectedIndex + delta + count) % count
            var list = root.aliasMode ? aliasList : appList
            list.positionViewAtIndex(selectedIndex, ListView.Contain)
        }

        function activateSelection() {
            if (root.aliasMode) {
                var aliases = root.filteredAliases
                if (aliases.length > 0) {
                    root.runAlias(aliases[launcherWindow.selectedIndex].name)
                } else {
                    var rest = root.filter.slice(1).trim()
                    if (rest.length > 0) root.runAlias(rest)
                }
                close()
                return
            }
            var apps = root.filteredApps
            var app = apps[launcherWindow.selectedIndex]
            if (app) { root.launchApp(app); close() }
        }

        Item {
            anchors.fill: parent
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) close()
                if (event.key === Qt.Key_Down)    launcherWindow.moveSelection(1)
                if (event.key === Qt.Key_Up)      launcherWindow.moveSelection(-1)
                if (event.key === Qt.Key_Return)  launcherWindow.activateSelection()
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
                            text: root.aliasMode ? ":" : "󰍉"
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
                    id: appList
                    visible: !root.aliasMode
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
                        width: appList.width
                        entry: modelData
                        selected: index === appList.currentIndex
                        launchAppCallback: root.launchApp
                        onActivated: root.close()
                    }
                }

                // Alias/function list (":" mode) — fills as the dump streams in.
                ListView {
                    id: aliasList
                    visible: root.aliasMode
                    width: parent.width
                    height: Math.min(root.filteredAliases.length * 44, 520)
                    topMargin: Theme.padding.sm
                    bottomMargin: Theme.padding.xs
                    model: root.filteredAliases
                    clip: true
                    currentIndex: launcherWindow.selectedIndex
                    boundsBehavior: Flickable.StopAtBounds
                    highlightMoveDuration: 0
                    highlightFollowsCurrentItem: true

                    delegate: AliasEntry {
                        required property var modelData
                        required property int index
                        width: aliasList.width
                        aliasName: modelData.name
                        definition: modelData.definition
                        selected: index === aliasList.currentIndex
                        launchCallback: root.runAlias
                        onActivated: root.close()
                    }
                }
            }
        }
    }
    }

    // Triggered via Hyprland global shortcut (see shell.qml for details).
}