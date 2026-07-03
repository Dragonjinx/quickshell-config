pragma Singleton

import QtQuick

// Material You / Matugen-inspired theme based on your existing colors.css
Singleton {
    readonly property color background:           "#0f1417"
    readonly property color surface:             "#1b2023"
    readonly property color surfaceContainer:    "#262b2e"
    readonly property color surfaceBright:       "#353a3d"
    readonly property color onBackground:        "#dfe3e7"
    readonly property color onSurface:           "#dfe3e7"
    readonly property color primary:             "#8ecff2"
    readonly property color primaryContainer:    "#004d67"
    readonly property color onPrimary:           "#003548"
    readonly property color secondary:           "#b5c9d7"
    readonly property color tertiary:            "#c9c1ea"
    readonly property color error:               "#ffb4ab"
    readonly property color outline:             "#8a9297"
    readonly property color outlineVariant:      "#40484d"
    readonly property color shadow:              "#000000"

    // Bar-specific
    readonly property color barBackground:       "#cc0f1417"  // semi-transparent
    readonly property color barText:             "#dfe3e7"
    readonly property color barActiveItem:       "#8ecff2"
    readonly property color barHoverItem:        "#353a3d"

    // Workspace
    readonly property color wsActive:            "#8ecff2"
    readonly property color wsInactive:          "#40484d"
    readonly property color wsUrgent:            "#ffb4ab"

    // Launcher
    readonly property color launcherBackground:  "#f00f1417"
    readonly property color launcherSurface:     "#1b2023"
    readonly property color launcherSelected:    "#8ecff2"
    readonly property color launcherText:        "#dfe3e7"
    readonly property color launcherDim:         "#40484d"

    // Font
    readonly property string fontFamily:         "Fira Sans"
    readonly property int barFontSize:           13
    readonly property int launcherFontSize:      12
}