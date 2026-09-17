pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// One place for every visual constant. Components read from here instead
// of threading a scaleFactor through every property.
Singleton {
    id: theme

    property string name: "nord"

    readonly property var options: [
        { id: "nord", label: "Nord" },
        { id: "gruvbox-dark", label: "Gruvbox Dark" },
        { id: "tokyo-night", label: "Tokyo Night" },
        { id: "catppuccin-mocha", label: "Catppuccin Mocha" },
        { id: "dracula", label: "Dracula" },
        { id: "one-dark", label: "One Dark" },
        { id: "solarized-dark", label: "Solarized Dark" },
        { id: "everforest-dark", label: "Everforest Dark" },
        { id: "rose-pine", label: "Rosé Pine" },
        { id: "kanagawa-wave", label: "Kanagawa Wave" }
    ]

    readonly property var palettes: ({
        "nord": { shell: "#2e3440", surface: "#3b4252", raised: "#434c5e", hover: "#4c566a", border: "#4c566a", fg: "#e5e9f0", fgMuted: "#a3acbd", accent: "#88c0d0", accentStrong: "#5e81ac", red: "#bf616a", orange: "#d08770", yellow: "#ebcb8b", green: "#a3be8c", purple: "#b48ead" },
        "gruvbox-dark": { shell: "#1d2021", surface: "#282828", raised: "#3c3836", hover: "#504945", border: "#504945", fg: "#ebdbb2", fgMuted: "#a89984", accent: "#8ec07c", accentStrong: "#458588", red: "#fb4934", orange: "#fe8019", yellow: "#fabd2f", green: "#b8bb26", purple: "#d3869b" },
        "tokyo-night": { shell: "#1a1b26", surface: "#24283b", raised: "#292e42", hover: "#3b4261", border: "#3b4261", fg: "#c0caf5", fgMuted: "#9aa5ce", accent: "#7dcfff", accentStrong: "#3d59a1", red: "#f7768e", orange: "#ff9e64", yellow: "#e0af68", green: "#9ece6a", purple: "#bb9af7" },
        "catppuccin-mocha": { shell: "#11111b", surface: "#1e1e2e", raised: "#313244", hover: "#45475a", border: "#45475a", fg: "#cdd6f4", fgMuted: "#a6adc8", accent: "#94e2d5", accentStrong: "#5b6ca8", red: "#f38ba8", orange: "#fab387", yellow: "#f9e2af", green: "#a6e3a1", purple: "#cba6f7" },
        "dracula": { shell: "#21222c", surface: "#282a36", raised: "#343746", hover: "#44475a", border: "#44475a", fg: "#f8f8f2", fgMuted: "#bfbfbf", accent: "#8be9fd", accentStrong: "#6d5f9e", red: "#ff5555", orange: "#ffb86c", yellow: "#f1fa8c", green: "#50fa7b", purple: "#bd93f9" },
        "one-dark": { shell: "#21252b", surface: "#282c34", raised: "#2c323c", hover: "#3e4451", border: "#3e4451", fg: "#abb2bf", fgMuted: "#7f848e", accent: "#56b6c2", accentStrong: "#3e6f9a", red: "#e06c75", orange: "#d19a66", yellow: "#e5c07b", green: "#98c379", purple: "#c678dd" },
        "solarized-dark": { shell: "#002b36", surface: "#073642", raised: "#164954", hover: "#285762", border: "#285762", fg: "#93a1a1", fgMuted: "#657b83", accent: "#2aa198", accentStrong: "#268bd2", red: "#dc322f", orange: "#cb4b16", yellow: "#b58900", green: "#859900", purple: "#d33682" },
        "everforest-dark": { shell: "#1e2326", surface: "#272e33", raised: "#2e383c", hover: "#374145", border: "#374145", fg: "#d3c6aa", fgMuted: "#859289", accent: "#83c092", accentStrong: "#5a8a80", red: "#e67e80", orange: "#e69875", yellow: "#dbbc7f", green: "#a7c080", purple: "#d699b6" },
        "rose-pine": { shell: "#191724", surface: "#1f1d2e", raised: "#26233a", hover: "#403d52", border: "#403d52", fg: "#e0def4", fgMuted: "#908caa", accent: "#9ccfd8", accentStrong: "#31748f", red: "#eb6f92", orange: "#ea9a97", yellow: "#f6c177", green: "#9ccfd8", purple: "#c4a7e7" },
        "kanagawa-wave": { shell: "#16161d", surface: "#1f1f28", raised: "#2a2a37", hover: "#363646", border: "#363646", fg: "#dcd7ba", fgMuted: "#8a8980", accent: "#7aa89f", accentStrong: "#4d6a9a", red: "#e46876", orange: "#ffa066", yellow: "#e6c384", green: "#98bb6c", purple: "#957fb8" }
    })

    readonly property var p: palettes[name] || palettes.nord

    readonly property color shell: p.shell
    readonly property color surface: p.surface
    readonly property color raised: p.raised
    readonly property color hover: p.hover
    readonly property color border: p.border
    readonly property color fg: p.fg
    readonly property color fgMuted: p.fgMuted
    readonly property color accent: p.accent
    readonly property color accentStrong: p.accentStrong
    readonly property color red: p.red
    readonly property color orange: p.orange
    readonly property color yellow: p.yellow
    readonly property color green: p.green
    readonly property color purple: p.purple

    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    // Single global UI scale. Sizes below are designed for ~1280 rows; a
    // 1440p screen runs at 1.125 (15px body text, 38px bar), 1080p at 0.9.
    readonly property real s: {
        var screens = Quickshell.screens;
        var h = screens.length > 0 ? screens[0].height : 1440;
        return Math.max(0.9, Math.min(1.25, h / 1280));
    }

    readonly property string font: "Iosevka Nerd Font"
    readonly property int fontSize: Math.round(13 * s)
    readonly property int fontSmall: Math.round(11 * s)
    readonly property int fontLarge: Math.round(16 * s)
    readonly property int iconSize: Math.round(14 * s)

    readonly property real barHeight: Math.round(34 * s)
    readonly property real islandHeight: Math.round(28 * s)
    readonly property real islandRadius: Math.round(8 * s)
    readonly property real popoverRadius: Math.round(10 * s)
    readonly property real controlRadius: Math.round(7 * s)
    readonly property real controlHeight: Math.round(30 * s)
    readonly property real gap: Math.round(8 * s)
    readonly property real pad: Math.round(12 * s)

    readonly property int animFast: 100
    readonly property int animNormal: 160

    function set(id) {
        for (var i = 0; i < options.length; i++) {
            if (options[i].id === id) {
                name = id;
                saveProc.command = ["sh", "-c", "d=${XDG_STATE_HOME:-$HOME/.local/state}/cornice; mkdir -p \"$d\"; printf '%s\\n' \"$1\" > \"$d/theme\"", "sh", id];
                saveProc.running = true;
                return;
            }
        }
    }

    Process {
        id: saveProc
    }

    Process {
        running: true
        command: ["sh", "-c", "cat \"${XDG_STATE_HOME:-$HOME/.local/state}/cornice/theme\" 2>/dev/null || printf nord"]
        stdout: StdioCollector {
            onStreamFinished: {
                var saved = this.text.trim();
                if (theme.palettes[saved])
                    theme.name = saved;
            }
        }
    }
}
