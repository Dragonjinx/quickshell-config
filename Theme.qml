pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Theme with presets: matugen (default), black, white, tokyonight, catppuccin.
// Switch via Theme.setMode("tokyonight") / Theme.setMode("catppuccin") etc.
// Dconf auto-switch maps dark -> catppuccin, light -> white.
Singleton {
    id: root

    // Current mode name. Dark default is catppuccin.
    property string mode: "catppuccin"

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
    property color success
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
    readonly property int mdiFontSize: 18
    readonly property int launchFontSize: 14

    // ── Design tokens (Material 3 scale, matching caelestia) ──
    readonly property QtObject spacing: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 20
        readonly property int xxl: 28
        readonly property int xxxl: 48
    }
    readonly property QtObject padding: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 20
        readonly property int xxl: 28
        readonly property int xxxl: 48
    }
    readonly property QtObject rounding: QtObject {
        readonly property int zero: 0
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 20
        readonly property int xxl: 28
        readonly property int xxxl: 48
    }

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
            success         = "#63d297"
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
            success         = "#1f883d"
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

        } else if (root.mode === "tokyonight") {
            // Tokyo Night (night) — https://github.com/tokyo-night
            bg              = "#16161e"
            surface         = "#1a1b26"
            surfCont        = "#292e42"
            surfBright      = "#3b4261"
            textBg          = "#c0caf5"
            textSurf        = "#a9b1d6"
            primary         = "#7aa2f7"
            primCont        = "#3d59a1"
            onPrim          = "#16161e"
            secondary       = "#a9b1d6"
            tertiary        = "#bb9af7"
            error           = "#f7768e"
            success         = "#9ece6a"
            outline         = "#565f89"
            outlineVar      = "#3b4261"
            barBg           = "#16161e"
            barText         = "#c0caf5"
            barHover        = "#3b4261"
            wsActive        = "#7aa2f7"
            wsActiveText    = "#16161e"
            wsInactive      = "#3b4261"
            wsUrgent        = "#f7768e"
            launchBg        = "#c016161e"
            launchSurface   = "#1a1b26"
            launchSel       = "#7aa2f7"
            launchText      = "#c0caf5"
            launchTextSel   = "#16161e"
            launchDim       = "#565f89"

        } else if (root.mode === "catppuccin") {
            // Catppuccin mocha — https://github.com/catppuccin
            bg              = "#11111b"
            surface         = "#1e1e2e"
            surfCont        = "#313244"
            surfBright      = "#45475a"
            textBg          = "#cdd6f4"
            textSurf        = "#cdd6f4"
            primary         = "#89b4fa"
            primCont        = "#458588"
            onPrim          = "#1e1e2e"
            secondary       = "#a6adc8"
            tertiary        = "#b4befe"
            error           = "#f38ba8"
            success         = "#a6e3a1"
            outline         = "#6c7086"
            outlineVar      = "#45475a"
            barBg           = "#1e1e2e"
            barText         = "#cdd6f4"
            barHover        = "#313244"
            wsActive        = "#b4befe"
            wsActiveText    = "#1e1e2e"
            wsInactive      = "#45475a"
            wsUrgent        = "#f38ba8"
            launchBg        = "#c01e1e2e"
            launchSurface   = "#1e1e2e"
            launchSel       = "#b4befe"
            launchText      = "#cdd6f4"
            launchTextSel   = "#1e1e2e"
            launchDim       = "#a6adc8"

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
            success         = "#63d297"
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

    // Persistent process to tell every running kitty instance to re-apply its
    // auto theme (*-theme.auto.conf) for the current system color scheme.
    // kitty's native portal trigger is unreliable on NixOS+Hyprland (#8811),
    // so we supply the reload trigger ourselves via remote control.
    Process {
        id: kittyThemeSwitcher
        running: false
    }

    function applyDconfValue(val) {
        val = val.trim().replace(/'/g, "")
        // dark scheme -> catppuccin (dark default); light -> white
        var newMode = "catppuccin"
        var scheme = "dark"
        if (val === "prefer-light") {
            newMode = "white"
            scheme = "light"
        }
        root.setMode(newMode)

        // listen_on unix:/tmp/kitty-rc -> /tmp/kitty-rc-<pid> per instance.
        // simulate_color_scheme_preference_change forces kitty to re-pick its
        // dark/light-theme.auto.conf and applies it to ALL windows (patch_colors).
        kittyThemeSwitcher.command = ["sh", "-c",
            "for s in /tmp/kitty-rc-*; do [ -S \"$s\" ] || continue; " +
            "$HOME/.nix-profile/bin/kitten @ --to \"unix:$s\" action " +
            "simulate_color_scheme_preference_change " + scheme +
            " >/dev/null 2>&1 || true; done"]
        kittyThemeSwitcher.running = true
    }

}