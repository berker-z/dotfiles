import QtQuick
import Quickshell.Hyprland
import qs

// Numbered chips. 1–5 are always shown; anything beyond that appears only
// while it exists. Active is filled, occupied is outlined, empty is dim.
Row {
    id: strip

    required property string monitor

    readonly property var monitorObj: {
        var mons = Hyprland.monitors.values || [];
        for (var i = 0; i < mons.length; i++)
            if (mons[i].name === monitor)
                return mons[i];
        return null;
    }
    readonly property int activeId: monitorObj && monitorObj.activeWorkspace ? monitorObj.activeWorkspace.id : -1

    readonly property var entries: {
        var seen = {};
        var out = [];
        var all = Hyprland.workspaces.values || [];
        for (var i = 0; i < all.length; i++) {
            var ws = all[i];
            if (!ws || ws.id <= 0)
                continue;
            seen[ws.id] = ws.toplevels ? ws.toplevels.values.length > 0 : true;
        }
        for (var n = 1; n <= 5; n++)
            out.push({ id: n, occupied: !!seen[n] });
        var extra = Object.keys(seen).map(Number).filter(function(k) { return k > 5; }).sort(function(a, b) { return a - b; });
        for (var e = 0; e < extra.length; e++)
            out.push({ id: extra[e], occupied: true });
        return out;
    }

    anchors.verticalCenter: parent.verticalCenter
    spacing: Math.round(3 * Theme.s)

    Repeater {
        model: strip.entries

        Rectangle {
            required property var modelData

            readonly property bool active: modelData.id === strip.activeId
            readonly property bool occupied: modelData.occupied

            width: Math.round(20 * Theme.s)
            height: Math.round(20 * Theme.s)
            radius: Math.round(5 * Theme.s)
            color: active ? Theme.accent : (area.containsMouse ? Theme.hover : "transparent")
            border.width: !active && occupied ? 1 : 0
            border.color: Theme.alpha(Theme.fgMuted, 0.5)

            Behavior on color {
                ColorAnimation { duration: Theme.animFast }
            }

            Text {
                anchors.centerIn: parent
                text: parent.modelData.id
                color: parent.active ? Theme.shell : (parent.occupied ? Theme.fg : Theme.alpha(Theme.fgMuted, 0.5))
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                font.weight: parent.active ? Font.Bold : Font.DemiBold
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + parent.modelData.id + " })")
            }
        }
    }
}
