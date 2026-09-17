pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// Wi-Fi via nmcli. Quickshell's Networking module knows whether the radio is
// on and gives us the device for scanning, but the network list and the
// connect flow still go through nmcli.
Singleton {
    id: wifi

    property var networks: []
    property string status: ""
    property string pendingPassword: ""
    property bool wanted: false

    readonly property var devices: (typeof Networking !== "undefined" && Networking && Networking.devices) ? Networking.devices.values : []
    readonly property var device: devices.find(function(d) { return d && d.type === DeviceType.Wifi; }) || null
    readonly property string iface: device ? (device.name || "") : ""
    readonly property bool enabled: (typeof Networking !== "undefined" && Networking) ? Networking.wifiEnabled : false
    readonly property var connected: networks.find(function(n) { return n.active; }) || null
    readonly property string ssid: connected ? connected.ssid : ""
    readonly property int signal: connected ? connected.signal : 0
    readonly property bool busy: connectProc.running || disconnectProc.running || toggleProc.running

    readonly property string icon: !enabled ? "󰖪" : (!connected ? "󰖩" : (signal > 75 ? "󰤨" : signal > 50 ? "󰤥" : signal > 25 ? "󰤢" : "󰤟"))

    function refresh() {
        if (!listProc.running)
            listProc.running = true;
    }

    function scan() {
        if (!scanProc.running) {
            status = "Scanning…";
            scanProc.running = true;
        }
    }

    function toggle() {
        if (toggleProc.running)
            return;
        toggleProc.command = ["nmcli", "radio", "wifi", enabled ? "off" : "on"];
        toggleProc.running = true;
    }

    function disconnect() {
        if (iface.length === 0 || disconnectProc.running)
            return;
        status = "Disconnecting…";
        disconnectProc.command = ["nmcli", "device", "disconnect", iface];
        disconnectProc.running = true;
    }

    function connect(ssid, password) {
        if (!ssid || connectProc.running)
            return;
        pendingPassword = password || "";
        status = "Connecting to " + ssid + "…";
        connectProc.command = pendingPassword.length > 0
            ? ["nmcli", "--ask", "dev", "wifi", "connect", ssid]
            : ["nmcli", "dev", "wifi", "connect", ssid];
        connectProc.running = true;
    }

    function secured(n) {
        return n && n.security && n.security.length > 0 && n.security !== "--";
    }

    function splitNm(line) {
        var parts = [];
        var cur = "";
        var esc = false;
        for (var i = 0; i < line.length; i++) {
            var ch = line.charAt(i);
            if (esc) {
                cur += ch;
                esc = false;
            } else if (ch === "\\") {
                esc = true;
            } else if (ch === ":") {
                parts.push(cur);
                cur = "";
            } else {
                cur += ch;
            }
        }
        parts.push(cur);
        return parts;
    }

    function parse(text) {
        var map = {};
        var order = [];
        var lines = text.split("\n");
        for (var i = 0; i < lines.length; i++) {
            if (!lines[i].length)
                continue;
            var parts = splitNm(lines[i]);
            if (parts.length < 4 || !parts[1])
                continue;
            var active = parts[0] === "*";
            var sig = Number(parts[3]) || 0;
            var cur = map[parts[1]];
            if (!cur) {
                cur = { ssid: parts[1], active: active, security: parts[2], signal: sig };
                map[parts[1]] = cur;
                order.push(parts[1]);
            } else if (active || sig > cur.signal) {
                cur.active = cur.active || active;
                cur.security = parts[2];
                cur.signal = sig;
            }
        }
        var rows = order.map(function(k) { return map[k]; });
        rows.sort(function(a, b) {
            if (a.active !== b.active)
                return a.active ? -1 : 1;
            return b.signal - a.signal;
        });
        networks = rows;
    }

    // Only keep the scanner running while a surface is actually showing
    // the list; callers set `wanted`.
    Binding {
        target: wifi.device
        property: "scannerEnabled"
        value: wifi.wanted && wifi.enabled
        when: wifi.device !== null
    }

    Timer {
        interval: wifi.wanted ? 6000 : 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: wifi.refresh()
    }

    Timer {
        id: clearStatus
        interval: 2500
        onTriggered: wifi.status = ""
    }

    Process {
        id: listProc
        command: ["nmcli", "-t", "-e", "yes", "-f", "IN-USE,SSID,SECURITY,SIGNAL", "dev", "wifi", "list", "--rescan", "no"]
        stdout: StdioCollector {
            onStreamFinished: wifi.parse(this.text)
        }
    }

    Process {
        id: scanProc
        command: ["nmcli", "dev", "wifi", "rescan"]
        onExited: {
            wifi.status = "";
            wifi.refresh();
        }
    }

    Process {
        id: toggleProc
        onExited: function(code) {
            wifi.status = code === 0 ? "" : "Could not toggle Wi-Fi";
            wifi.refresh();
            clearStatus.restart();
        }
    }

    Process {
        id: disconnectProc
        onExited: function(code) {
            wifi.status = code === 0 ? "" : "Disconnect failed";
            wifi.refresh();
            clearStatus.restart();
        }
    }

    Process {
        id: connectProc
        stdinEnabled: true
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onStarted: {
            if (wifi.pendingPassword.length > 0) {
                write(wifi.pendingPassword + "\n");
                wifi.pendingPassword = "";
            }
        }
        onExited: function(code) {
            wifi.status = code === 0 ? "" : "Connection failed";
            wifi.refresh();
            clearStatus.restart();
        }
    }
}
