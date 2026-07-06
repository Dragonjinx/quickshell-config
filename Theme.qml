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
    property color wsActiveText
    property color wsInactive
    property color wsUrgent
    property color launchBg
    property color launchSurface
    property color launchSel
    property color launchText
    property color launchTextSel
    property color launchDim

    readonly property string fontFam: "BlexMono Nerd Font"
    readonly property int barFontSize: 15
    readonly property int launchFontSize: 14

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
            wsActive        = "#ffffff"
            wsActiveText    = "#000000"
            wsInactive      = "#333333"
            wsUrgent        = "#ffb4ab"
            launchBg        = "#f0000000"
            launchSurface   = "#1a1a1a"
            launchSel       = "#ffffff"
            launchText      = "#ffffff"
            launchTextSel   = "#000000"
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
            wsActive        = "#ffffff"
            wsActiveText    = "#000000"
            wsInactive      = "#c4c7c9"
            wsUrgent        = "#ba1a1a"
            launchBg        = "#f0ffffff"
            launchSurface   = "#f5f5f5"
            launchSel       = "#333333"
            launchText      = "#000000"
            launchTextSel   = "#ffffff"
            launchDim       = "#8a9297"

        } else {
            // default: dark mode (same as black)
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
            wsActive        = "#ffffff"
            wsActiveText    = "#000000"
            wsInactive      = "#333333"
            wsUrgent        = "#ffb4ab"
            launchBg        = "#f0000000"
            launchSurface   = "#1a1a1a"
            launchSel       = "#ffffff"
            launchText      = "#ffffff"
            launchTextSel   = "#000000"
            launchDim       = "#666666"
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
        if (val === "prefer-dark") {
            root.setMode("black")
            alacrittySwitcher.command = ["cp", "-f", "/home/abhilekh/.config/alacritty/adarkkitty.toml", "/home/abhilekh/.config/alacritty/alacritty.toml"]
            alacrittySwitcher.running = true
        } else if (val === "prefer-light") {
            root.setMode("white")
            alacrittySwitcher.command = ["cp", "-f", "/home/abhilekh/.config/alacritty/alightkitty.toml", "/home/abhilekh/.config/alacritty/alacritty.toml"]
            alacrittySwitcher.running = true
        } else {
            root.setMode("black")
            alacrittySwitcher.command = ["cp", "-f", "/home/abhilekh/.config/alacritty/adarkkitty.toml", "/home/abhilekh/.config/alacritty/alacritty.toml"]
            alacrittySwitcher.running = true
        }
    }

    // Persistent process for switching Alacritty theme
    Process {
        id: alacrittySwitcher
        running: false
    }
}