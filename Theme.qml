pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// ============================================================================
// Theme.qml — palette→role mapping for the quickshell bar.
//
// Two layers:
//   1. SEMANTIC ROLES (below) — the ONLY colors widgets reference. This list
//      is fixed and never changes when we add/edit a theme. Widgets only ever
//      read these, so we never touch widget files to re-style.
//   2. THEME PALETTES + MAPPING — each theme supplies its own named color set
//      (e.g. catppuccin: rosewater/flamingo/mauve/...) and a small mapping
//      function that assigns those palette colors to the semantic roles above.
//
// To add a theme you only write a palette object (its natural colors) and one
// mapping function — nothing else.
//
// Families (modes): `catppuccin` and `tokyo`. Each family has a dark and a
// light palette — selected by the `light` flag (driven by dconf scheme):
//   catppuccin: dark=mocha, light=latte
//   tokyo:      dark=tokyo night, light=tokyo night light
// Pick a family via setMode("catppuccin"|"tokyo"); dconf chooses light/dark.
// ============================================================================
Singleton {
    id: root

    // Current theme FAMILY. Dark/light is selected by `light` (from dconf).
    property string mode: "catppuccin"

    // Light or dark variant of the active family (driven by dconf scheme).
    property bool light: false

    // ────────────────────────────────────────────────────────────────────────
    // 1. SEMANTIC ROLES — widgets reference these names only.
    //    (Do not rename/reorder; widget files depend on them.)
    // ────────────────────────────────────────────────────────────────────────
    property color bg                // deepest background (e.g. crust)
    property color surface           // main surface (e.g. base)
    property color surfCont          // raised container tone
    property color surfBright        // brightest surface hover
    property color textBg            // primary foreground text
    property color textSurf          // secondary / muted text
    property color primary           // main accent (active ws, calendar today)
    property color primCont          // accent container (occupied ws fill)
    property color onPrim            // text/icon on top of primary
    property color secondary         // secondary informational text
    property color tertiary          // tertiary accent
    property color error             // error / critical
    property color success           // success / charging / healthy
    property color amber             // warning tier (peach/amber)
    property color blue              // bluetooth active accent
    property color lavender          // wifi active accent
    property color yellow            // battery mid-high
    property color maroon            // battery low
    property color batFull           // battery icon tier 4 (highest)
    property color batHigh           // battery icon tier 3
    property color batMid            // battery icon tier 2
    property color batLow            // battery icon tier 1
    property color batCrit           // battery icon tier 0 (critical)
    property color outline           // borders / faint structure
    property color outlineVar        // subtle borders
    property color barBg             // bar background (opaque)
    property color barText           // default bar text
    property color barHover          // bar hover highlight
    property color wsActive          // active workspace fill
    property color wsActiveText      // text on active workspace
    property color wsInactive        // empty workspace fill
    property color wsUrgent          // urgent workspace fill
    property color launchBg          // launcher backdrop
    property color launchSurface     // launcher surface
    property color launchSel         // launcher selection
    property color launchText        // launcher text
    property color launchTextSel     // launcher selected text
    property color launchDim         // launcher muted text

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

    function setLight(isLight) {
        root.light = isLight
        applyMode()
    }

    // ────────────────────────────────────────────────────────────────────────
    // 2. COLOR HELPERS
    // ────────────────────────────────────────────────────────────────────────
    function _alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a)
    }
    // Linear blend: t=0 -> c1, t=1 -> c2
    function _mix(c1, c2, t) {
        return Qt.rgba(
            c1.r * (1 - t) + c2.r * t,
            c1.g * (1 - t) + c2.g * t,
            c1.b * (1 - t) + c2.b * t,
            1)
    }

    // ────────────────────────────────────────────────────────────────────────
    // 3. THEME PALETTES — each theme's natural, named colors.
    // ────────────────────────────────────────────────────────────────────────
    readonly property QtObject catppuccinMocha: QtObject {
        readonly property color rosewater: "#f5e0dc"
        readonly property color flamingo:  "#f2cdcd"
        readonly property color pink:      "#f5c2e7"
        readonly property color mauve:     "#cba6f7"
        readonly property color red:       "#f38ba8"
        readonly property color maroon:    "#eba0ac"
        readonly property color peach:     "#fab387"
        readonly property color yellow:    "#f9e2af"
        readonly property color green:     "#a6e3a1"
        readonly property color teal:      "#94e2d5"
        readonly property color sky:       "#89dceb"
        readonly property color sapphire:  "#74c7ec"
        readonly property color blue:      "#89b4fa"
        readonly property color lavender:  "#b4befe"
        readonly property color text:      "#cdd6f4"
        readonly property color subtext1:  "#bac2de"
        readonly property color subtext0:  "#a6adc8"
        readonly property color overlay2:  "#9399b2"
        readonly property color overlay1:  "#7f849c"
        readonly property color overlay0:  "#6c7086"
        readonly property color surface2:  "#585b70"
        readonly property color surface1:  "#45475a"
        readonly property color surface0:  "#313244"
        readonly property color base:      "#1e1e2e"
        readonly property color mantle:    "#181825"
        readonly property color crust:     "#11111b"
    }

    readonly property QtObject catppuccinLatte: QtObject {
        readonly property color rosewater: "#dc8a78"
        readonly property color flamingo:  "#dd7878"
        readonly property color pink:      "#ea76cb"
        readonly property color mauve:     "#8839ef"
        readonly property color red:       "#d20f39"
        readonly property color maroon:    "#e64553"
        readonly property color peach:     "#fe640b"
        readonly property color yellow:    "#df8e1d"
        readonly property color green:     "#40a02b"
        readonly property color teal:      "#179299"
        readonly property color sky:       "#04a5e5"
        readonly property color sapphire:  "#209fb5"
        readonly property color blue:      "#1e66f5"
        readonly property color lavender:  "#7287fd"
        readonly property color text:      "#4c4f69"
        readonly property color subtext1:  "#5c5f77"
        readonly property color subtext0:  "#6c6f85"
        readonly property color overlay2:  "#7c7f93"
        readonly property color overlay1:  "#8c8fa1"
        readonly property color overlay0:  "#9ca0b0"
        readonly property color surface2:  "#acb0be"
        readonly property color surface1:  "#bcc0cc"
        readonly property color surface0:  "#ccd0da"
        readonly property color base:      "#eff1f5"
        readonly property color mantle:    "#e6e9ef"
        readonly property color crust:     "#dce0e8"
    }

    readonly property QtObject tokyoNight: QtObject {
        readonly property color bg:            "#1a1b26"
        readonly property color bg_dark:       "#16161e"
        readonly property color bg_highlight:  "#292e42"
        readonly property color bg_visual:     "#283457"
        readonly property color fg:            "#c0caf5"
        readonly property color fg_dark:       "#a9b1d6"
        readonly property color comment:       "#565f89"
        readonly property color blue:          "#7aa2f7"
        readonly property color blue0:         "#3d59a1"
        readonly property color cyan:          "#7dcfff"
        readonly property color teal:          "#73daca"
        readonly property color green:         "#9ece6a"
        readonly property color yellow:        "#e0af68"
        readonly property color orange:        "#ff9e64"
        readonly property color red:           "#f7768e"
        readonly property color magenta:       "#bb9af7"
        readonly property color purple:        "#9d7cd8"
        // derived soft periwinkle for the lavender wifi accent
        readonly property color lavender:      "#b8a6f0"
    }

    readonly property QtObject tokyoDay: QtObject {
        readonly property color bg:            "#e1e2e7"
        readonly property color bg_dark:       "#d0d5e3"
        readonly property color bg_highlight:  "#c4c8da"
        readonly property color bg_visual:     "#b7c1e3"
        readonly property color fg:            "#3760bf"
        readonly property color fg_dark:       "#6172b0"
        readonly property color comment:       "#848cb5"
        readonly property color blue:          "#2e7de9"
        readonly property color blue0:         "#7890dd"
        readonly property color cyan:          "#007197"
        readonly property color teal:          "#118c74"
        readonly property color green:         "#587539"
        readonly property color yellow:        "#8c6c3e"
        readonly property color orange:        "#b15c00"
        readonly property color red:           "#f52a65"
        readonly property color magenta:       "#9854f1"
        readonly property color purple:        "#7847bd"
        readonly property color lavender:      "#6f80f5"
    }

    // ────────────────────────────────────────────────────────────────────────
    // 4. MAPPINGS — palette → semantic roles. ONLY per-theme code we maintain.
    // ────────────────────────────────────────────────────────────────────────

    // Catppuccin (shared by mocha + latte)
    function _applyCatppuccin(p) {
        bg           = p.crust
        surface      = p.base
        surfCont     = p.surface0
        surfBright   = p.surface1
        textBg       = p.text
        textSurf     = p.subtext0
        primary      = p.mauve
        primCont     = root._mix(p.base, p.mauve, 0.30)
        onPrim       = p.base
        secondary    = p.subtext0
        tertiary     = p.lavender
        error        = p.red
        success      = p.green
        amber        = p.peach
        blue         = p.blue
        lavender     = p.lavender
        yellow       = p.yellow
        maroon       = p.maroon
        // battery gradient: green > yellow > peach > maroon > red
        batFull      = p.green
        batHigh      = p.yellow
        batMid       = p.peach
        batLow       = p.maroon
        batCrit      = p.red
        outline      = p.overlay0
        outlineVar   = p.surface1
        barBg        = p.base
        barText      = p.text
        barHover     = p.surface0
        wsActive     = p.mauve
        wsActiveText = p.base
        wsInactive   = p.surface1
        wsUrgent     = p.red
        launchBg     = p.base
        launchSurface= p.surface0
        launchSel    = p.mauve
        launchText   = p.text
        launchTextSel= p.base
        launchDim    = p.subtext0
    }

    // Tokyo Night / Day
    function _applyTokyo(p) {
        bg           = p.bg_dark
        surface      = p.bg
        surfCont     = p.bg_highlight
        surfBright   = root._mix(p.bg_dark, p.fg, 0.18)
        textBg       = p.fg
        textSurf     = p.fg_dark
        primary      = p.blue
        primCont     = root._mix(p.bg_dark, p.blue, 0.35)
        onPrim       = p.bg_dark
        secondary    = p.fg_dark
        tertiary     = p.magenta
        error        = p.red
        success      = p.green
        amber        = p.orange
        blue         = p.blue
        lavender     = p.lavender
        yellow       = p.yellow
        maroon       = root._mix(p.red, p.bg_dark, 0.45)
        // battery gradient: teal > green > yellow > orange > red
        batFull      = p.teal
        batHigh      = p.green
        batMid       = p.yellow
        batLow       = p.orange
        batCrit      = p.red
        outline      = p.comment
        outlineVar   = p.bg_highlight
        barBg        = p.bg_dark
        barText      = p.fg
        barHover     = p.bg_highlight
        wsActive     = p.blue
        wsActiveText = p.bg_dark
        wsInactive   = p.bg_highlight
        wsUrgent     = p.red
        launchBg     = p.bg_dark
        launchSurface= p.bg_highlight
        launchSel    = p.blue
        launchText   = p.fg
        launchTextSel= p.bg_dark
        launchDim    = p.comment
    }

    // Only catppuccin + tokyo themes remain (mono black/white removed).

    function applyMode() {
        if (root.mode === "catppuccin") {
            if (root.light) root._applyCatppuccin(root.catppuccinLatte)
            else            root._applyCatppuccin(root.catppuccinMocha)

        } else if (root.mode === "tokyo") {
            if (root.light) root._applyTokyo(root.tokyoDay)
            else            root._applyTokyo(root.tokyoNight)

        } else {
            // unknown family -> fall back to catppuccin dark
            root._applyCatppuccin(root.catppuccinMocha)
        }

        root.syncGreylineTheme()
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
    Process {
        id: kittyThemeSwitcher
        running: false
    }

    // Persistent process to sync greyline wallpaper theme with the active
    // quickshell theme (family + light/dark).
    // Reuses greyline's own one-shot render unit (greyline.service, the same
    // Type=oneshot service the systemd timer activates every minute) so the
    // wallpaper updates immediately instead of waiting for the next tick.
    Process {
        id: greylineThemeSwitcher
        running: false
    }

    function greylineThemeName() {
        var name
        if (root.mode === "catppuccin") {
            name = root.light ? "catppuccin-latte" : "catppuccin-mocha"
        } else if (root.mode === "tokyo") {
            name = root.light ? "tokyo-night-light" : "tokyo-night-dark"
        } else {
            // unknown family -> greyline catppuccin dark
            name = "catppuccin-mocha"
        }
        return name
    }

    function syncGreylineTheme() {
        greylineThemeSwitcher.command = ["sh", "-c",
            "$HOME/.nix-profile/bin/greyline config set theme " + root.greylineThemeName() +
            " >/dev/null 2>&1 && systemctl --user start greyline.service"]
        greylineThemeSwitcher.running = true
    }

    function applyDconfValue(val) {
        val = val.trim().replace(/'/g, "")
        // dconf scheme picks the light/dark variant WITHIN the active family.
        // Family (mode) is chosen manually via setMode("catppuccin"|"tokyo").
        var scheme = "dark"
        if (val === "prefer-light") {
            scheme = "light"
        }
        root.setLight(scheme === "light")

        // listen_on unix:/tmp/kitty-rc -> /tmp/kitty-rc-<pid> per instance.
        kittyThemeSwitcher.command = ["sh", "-c",
            "for s in /tmp/kitty-rc-*; do [ -S \"$s\" ] || continue; " +
            "$HOME/.nix-profile/bin/kitten @ --to \"unix:$s\" action " +
            "simulate_color_scheme_preference_change " + scheme +
            " >/dev/null 2>&1 || true; done"]
        kittyThemeSwitcher.running = true
    }

}
