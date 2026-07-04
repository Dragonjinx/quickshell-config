pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Theme with three presets: matugen (default), black, white.
// Switch via Theme.setMode("black") or Theme.setMode("white").
Singleton {
    id: root

    // Current mode name
    property string mode: "matugen"

    // Color properties (update when mode changes)
    property color bg
    property color surface
    property color surfCont
    property color surfBright
    property color textBg
    property color textSurf
    property color primary
    property color primCont
    property color onPrim
    property color secondary
    property color tertiary
    property color error
    property color outline
    property color outlineVar
    property color barBg
    property color barText
    property color barHover
    property color wsActive
    property color wsInactive
    property color wsUrgent
    property color launchBg
    property color launchSurface
    property color launchSel
    property color launchText
    property color launchDim

    readonly property string fontFam: "JetBrainsMono Nerd Font"
    readonly property int barFontSize: 13
    readonly property int launchFontSize: 12

    function setMode(newMode) {
        root.mode = newMode
        applyMode()
    }

    function applyMode() {
        if (root.mode === "black") {
            bg              = "#000000"
            surface         = "#1a1a1a"
            surfCont        = "#262626"
            surfBright      = "#333333"
            textBg          = "#ffffff"
            textSurf        = "#ffffff"
            primary         = "#8ecff2"
            primCont        = "#004d67"
            onPrim          = "#000000"
            secondary       = "#b5c9d7"
            tertiary        = "#c9c1ea"
            error           = "#ffb4ab"
            outline         = "#666666"
            outlineVar      = "#404040"
            barBg           = "#cc000000"
            barText         = "#ffffff"
            barHover        = "#333333"
            wsActive        = "#8ecff2"
            wsInactive      = "#333333"
            wsUrgent        = "#ffb4ab"
            launchBg        = "#f0000000"
            launchSurface   = "#1a1a1a"
            launchSel       = "#8ecff2"
            launchText      = "#ffffff"
            launchDim       = "#666666"

        } else if (root.mode === "white") {
            bg              = "#ffffff"
            surface         = "#f5f5f5"
            surfCont        = "#ebebeb"
            surfBright      = "#e0e0e0"
            textBg          = "#000000"
            textSurf        = "#000000"
            primary         = "#006494"
            primCont        = "#c2e8ff"
            onPrim          = "#ffffff"
            secondary       = "#4a5d68"
            tertiary        = "#6b62a0"
            error           = "#ba1a1a"
            outline         = "#8a9297"
            outlineVar      = "#c4c7c9"
            barBg           = "#ccffffff"
            barText         = "#000000"
            barHover        = "#e0e0e0"
            wsActive        = "#006494"
            wsInactive      = "#c4c7c9"
            wsUrgent        = "#ba1a1a"
            launchBg        = "#f0ffffff"
            launchSurface   = "#f5f5f5"
            launchSel       = "#006494"
            launchText      = "#000000"
            launchDim       = "#8a9297"

        } else {
            // matugen (default)
            bg              = "#0f1417"
            surface         = "#1b2023"
            surfCont        = "#262b2e"
            surfBright      = "#353a3d"
            textBg          = "#dfe3e7"
            textSurf        = "#dfe3e7"
            primary         = "#8ecff2"
            primCont        = "#004d67"
            onPrim          = "#003548"
            secondary       = "#b5c9d7"
            tertiary        = "#c9c1ea"
            error           = "#ffb4ab"
            outline         = "#8a9297"
            outlineVar      = "#40484d"
            barBg           = "#cc0f1417"
            barText         = "#dfe3e7"
            barHover        = "#353a3d"
            wsActive        = "#8ecff2"
            wsInactive      = "#40484d"
            wsUrgent        = "#ffb4ab"
            launchBg        = "#f00f1417"
            launchSurface   = "#1b2023"
            launchSel       = "#8ecff2"
            launchText      = "#dfe3e7"
            launchDim       = "#40484d"
        }
    }

    Component.onCompleted: applyMode()

    // --- Auto-detect dark/light mode from dconf (event-driven) ---
    // Uses dconf watch for real-time updates instead of polling
    Process {
        id: dconfInit
        command: ["dconf", "read", "/org/gnome/desktop/interface/color-scheme"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                applyDconfValue(line)
            }
        }
    }

    Process {
        id: dconfWatch
        command: ["dconf", "watch", "/org/gnome/desktop/interface/color-scheme"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                // dconf watch outputs lines like:
                //   (path):  'prefer-dark'
                // We only care about the value line
                var trimmed = line.trim()
                if (trimmed.charAt(0) === "'") {
                    applyDconfValue(trimmed)
                }
            }
        }
    }

    function applyDconfValue(val) {
        val = val.trim().replace(/'/g, "")
        if (val === "prefer-dark") root.setMode("black")
        else if (val === "prefer-light") root.setMode("white")
    }
}