import QtQuick
import Quickshell
import Quickshell.Hyprland

// Shows the title of the currently focused active toplevel.
Text {
    id: root

    property bool separateOutputs: true

    height: parent?.implicitHeight ?? 30
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    font.pixelSize: Theme.barFontSize
    color: Theme.barText
    opacity: 0.9
    text: {
        const toplevel = Hyprland.activeToplevel
        if (!toplevel) return ""
        const title = toplevel.title ?? ""

        // Rewrite patterns (mirroring your waybar config)
        if (title.endsWith(" - Brave")) return title.slice(0, -7)
        if (title.endsWith(" - Chromium")) return title.slice(0, -10)
        if (title.endsWith(" - Brave Search")) return title.slice(0, -15)
        if (title.endsWith(" - Outlook")) return title.slice(0, -9)
        if (title.includes("Microsoft Teams")) return title.replace("Microsoft Teams", "").trim()
        return title
    }
}