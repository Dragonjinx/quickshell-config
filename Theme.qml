pragma Singleton

import Quickshell
import QtQuick

// Material You / Matugen-inspired theme based on your existing colors.css
Singleton {
    // Background & Surface
    readonly property color bg:              "#0f1417"
    readonly property color surface:         "#1b2023"
    readonly property color surfCont:        "#262b2e"
    readonly property color surfBright:      "#353a3d"

    // Text
    readonly property color textBg:          "#dfe3e7"
    readonly property color textSurf:        "#dfe3e7"

    // Accents
    readonly property color primary:         "#8ecff2"
    readonly property color primCont:        "#004d67"
    readonly property color onPrim:          "#003548"
    readonly property color secondary:       "#b5c9d7"
    readonly property color tertiary:        "#c9c1ea"
    readonly property color error:           "#ffb4ab"

    // Outlines
    readonly property color outline:         "#8a9297"
    readonly property color outlineVar:      "#40484d"

    // Bar-specific
    readonly property color barBg:           "#cc0f1417"
    readonly property color barText:         "#dfe3e7"
    readonly property color barHover:        "#353a3d"

    // Workspace colors
    readonly property color wsActive:        "#8ecff2"
    readonly property color wsInactive:      "#40484d"
    readonly property color wsUrgent:        "#ffb4ab"

    // Launcher colors
    readonly property color launchBg:        "#f00f1417"
    readonly property color launchSurface:   "#1b2023"
    readonly property color launchSel:       "#8ecff2"
    readonly property color launchText:      "#dfe3e7"
    readonly property color launchDim:       "#40484d"

    // Font
    readonly property string fontFam:        "JetBrainsMono Nerd Font"
    readonly property int barFontSize:       13
    readonly property int launchFontSize:    12
}