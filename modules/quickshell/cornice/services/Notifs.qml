pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// mako's active list plus its history, merged into one newest-first list.
// History entries cannot be deleted through makoctl, so "clearing" one just
// hides its id for the rest of the session.
Singleton {
    id: notifs

    property var items: []
    property var hidden: ({})

    readonly property int count: items.length

    readonly property var groups: {
        var map = {};
        var order = [];
        for (var i = 0; i < items.length; i++) {
            var n = items[i];
            if (!map[n.app]) {
                map[n.app] = [];
                order.push(n.app);
            }
            map[n.app].push(n);
        }
        var out = [];
        for (var j = 0; j < order.length; j++) {
            var list = map[order[j]];
            out.push({ app: order[j], items: list, newest: list[0].id });
        }
        out.sort(function(a, b) { return b.newest - a.newest; });
        return out;
    }

    function refresh() {
        if (!listProc.running)
            listProc.running = true;
    }

    function parse(text) {
        var parsed;
        try {
            parsed = JSON.parse(text.length > 0 ? text : "{}");
        } catch (e) {
            items = [];
            return;
        }
        var out = [];
        var seen = {};
        function add(list, live) {
            if (!list)
                return;
            for (var i = 0; i < list.length; i++) {
                var it = list[i];
                var id = Number(it.id);
                if (isNaN(id) || seen[id] || (!live && hidden[id]))
                    continue;
                seen[id] = true;
                out.push({
                    id: id,
                    live: live,
                    app: String(it.app_name || it.desktop_entry || "System"),
                    summary: String(it.summary || "Notification"),
                    body: String(it.body || ""),
                    urgency: String(it.urgency || "normal"),
                    icon: String(it.app_icon || "")
                });
            }
        }
        add(parsed.active, true);
        add(parsed.history, false);
        out.sort(function(a, b) { return b.id - a.id; });
        items = out;
    }

    function hide(list) {
        var h = Object.assign({}, hidden);
        var ids = {};
        for (var i = 0; i < list.length; i++) {
            if (!list[i].live)
                h[list[i].id] = true;
            ids[list[i].id] = true;
        }
        hidden = h;
        items = items.filter(function(n) { return !ids[n.id]; });
    }

    function dismiss(n) {
        if (n.live)
            Quickshell.execDetached(["makoctl", "dismiss", "-n", String(n.id), "--no-history"]);
        hide([n]);
        later.restart();
    }

    function dismissGroup(group) {
        var args = ["sh", "-c", "for id in \"$@\"; do makoctl dismiss -n \"$id\" --no-history; done", "sh"];
        for (var i = 0; i < group.items.length; i++)
            if (group.items[i].live)
                args.push(String(group.items[i].id));
        if (args.length > 4)
            Quickshell.execDetached(args);
        hide(group.items);
        later.restart();
    }

    function dismissAll() {
        Quickshell.execDetached(["makoctl", "dismiss", "--all", "--no-history"]);
        hide(items);
        later.restart();
    }

    Timer {
        id: later
        interval: 250
        onTriggered: notifs.refresh()
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: notifs.refresh()
    }

    Process {
        id: listProc
        command: ["sh", "-c", "printf '{\"active\":'; makoctl list -j 2>/dev/null || printf '[]'; printf ',\"history\":'; makoctl history -j 2>/dev/null || printf '[]'; printf '}'"]
        stdout: StdioCollector {
            onStreamFinished: notifs.parse(this.text.trim())
        }
    }
}
