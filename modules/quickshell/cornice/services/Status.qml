pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The three toggles that live outside any Quickshell service: mako's DND
// mode, the Tailscale exit node, and the idle inhibitor. Polled once here;
// every surface binds to the same values.
Singleton {
    id: status

    property bool dnd: false
    property bool vpn: false
    property bool keepAwake: false
    property bool vpnBusy: false
    property bool exitNodeAvailable: false

    readonly property string exitNodeIp: "100.118.69.26"
    readonly property string exitNodeId: "nxLigg91DC21CNTRL"

    function refresh() {
        if (!dndProc.running)
            dndProc.running = true;
        if (!vpnProc.running)
            vpnProc.running = true;
        if (!exitNodeProc.running)
            exitNodeProc.running = true;
    }

    function toggleDnd() {
        dnd = !dnd;
        Quickshell.execDetached(["sh", "-c", dnd ? "makoctl mode -a dnd" : "makoctl mode -r dnd"]);
        settle.restart();
    }

    function toggleVpn() {
        if (vpnBusy || !exitNodeAvailable)
            return;
        vpnBusy = true;
        vpnToggle.command = ["sh", "-c", "ts=$(command -v tailscale || printf /run/current-system/sw/bin/tailscale); if $ts debug prefs 2>/dev/null | grep -Fq \"\\\"ExitNodeID\\\": \\\"$2\\\"\"; then $ts set --exit-node=; else $ts set --exit-node=\"$1\" --exit-node-allow-lan-access=false; fi", "sh", exitNodeIp, exitNodeId];
        vpnToggle.running = true;
    }

    function toggleKeepAwake() {
        keepAwake = !keepAwake;
    }

    // shell.qml holds a Wayland idle-inhibit; this adds a logind inhibitor
    // too, which hypridle honours (ignore_dbus_inhibit = false) and which
    // `systemd-inhibit --list` shows, so the state is checkable.
    Process {
        running: status.keepAwake
        command: ["systemd-inhibit", "--what=idle", "--who=cornice", "--why=Keep awake toggled on the bar", "--mode=block", "sleep", "infinity"]
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: status.refresh()
    }

    Timer {
        id: settle
        interval: 400
        onTriggered: status.refresh()
    }

    Process {
        id: dndProc
        command: ["sh", "-c", "makoctl mode 2>/dev/null | grep -qx dnd && printf 1 || printf 0"]
        stdout: StdioCollector {
            onStreamFinished: status.dnd = this.text.trim() === "1"
        }
    }

    Process {
        id: vpnProc
        command: ["sh", "-c", "tailscale debug prefs 2>/dev/null | grep -Fq '\"ExitNodeID\": \"" + status.exitNodeId + "\"' && printf 1 || printf 0"]
        stdout: StdioCollector {
            onStreamFinished: status.vpn = this.text.trim() === "1"
        }
    }

    Process {
        id: exitNodeProc
        command: ["sh", "-c", "tailscale exit-node list 2>/dev/null | grep -Fq '" + status.exitNodeIp + "' && printf 1 || printf 0"]
        stdout: StdioCollector {
            onStreamFinished: status.exitNodeAvailable = this.text.trim() === "1"
        }
    }

    Process {
        id: vpnToggle
        onExited: {
            status.vpnBusy = false;
            status.refresh();
        }
    }
}
