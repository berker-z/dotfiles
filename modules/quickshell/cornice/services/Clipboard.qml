pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// cliphist history. Thumbnails for image entries are rendered by
// cornice-thumbs into the cache dir; the list refresh kicks that off.
Singleton {
    id: clipboard

    property var entries: []
    property string status: ""

    readonly property string thumbDir: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/cornice/cliphist-thumbs"

    function thumb(id) {
        return "file://" + thumbDir + "/" + id + ".png";
    }

    function refresh() {
        if (!thumbProc.running)
            thumbProc.running = true;
        if (!listProc.running)
            listProc.running = true;
    }

    function parse(text) {
        var rows = [];
        var lines = text.split("\n");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            var tab = line.indexOf("\t");
            if (tab <= 0)
                continue;
            var id = line.slice(0, tab);
            var preview = line.slice(tab + 1)
                .replace(/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/g, "")
                .replace(/\s+/g, " ")
                .trim();
            var binary = preview.indexOf("[[ binary data") === 0;
            var meta = binary ? preview.replace(/^\[\[ binary data /, "").replace(/ \]\]$/, "") : "";
            rows.push({
                id: id,
                key: line,
                preview: binary ? "Image" : (preview.length > 0 ? preview : "(empty)"),
                meta: meta,
                binary: binary
            });
        }
        entries = rows;
    }

    function copy(entry, done) {
        if (!entry || copyProc.running)
            return;
        status = "Copying…";
        copyProc.onDone = done;
        copyProc.command = entry.binary
            ? ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", entry.key]
            : ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy --type 'text/plain;charset=utf-8'", "sh", entry.key];
        copyProc.running = true;
    }

    function remove(entry) {
        if (!entry)
            return;
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "sh", entry.key]);
        entries = entries.filter(function(e) { return e.id !== entry.id; });
        later.restart();
    }

    function wipe() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        entries = [];
    }

    Timer {
        id: later
        interval: 300
        onTriggered: clipboard.refresh()
    }

    Timer {
        id: clearStatus
        interval: 1500
        onTriggered: clipboard.status = ""
    }

    Process {
        id: thumbProc
        command: ["cornice-thumbs"]
        onExited: if (!listProc.running) listProc.running = true
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: clipboard.parse(this.text)
        }
    }

    Process {
        id: copyProc
        property var onDone: null
        onExited: function(code) {
            clipboard.status = code === 0 ? "Copied" : "Copy failed";
            clearStatus.restart();
            if (code === 0 && onDone)
                onDone();
            onDone = null;
        }
    }
}
