pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ASUS platform profile (Quiet / Balanced / Turbo) through
// scripts/asus-power-profile.sh, the same helper the laptop waybar used.
// `present` is false when the script reports "unknown", i.e. no
// /sys/firmware/acpi/platform_profile — so the item never shows on the
// desktop. mock("balanced") previews it anywhere.
Singleton {
    id: pp

    property string mockClass: ""
    property string reported: ""
    property bool busy: false

    readonly property string script: Quickshell.env("HOME") + "/dotfiles/scripts/asus-power-profile.sh"
    readonly property string profile: mockClass.length > 0 ? mockClass : reported
    readonly property bool present: profile === "quiet" || profile === "balanced" || profile === "performance"

    readonly property string label: profile === "quiet" ? "Quiet" : profile === "balanced" ? "Balanced" : profile === "performance" ? "Turbo" : "?"
    readonly property string icon: profile === "quiet" ? "󰌪" : profile === "balanced" ? "󰾅" : profile === "performance" ? "󰓅" : "󰾆"

    function refresh() {
        if (!statusProc.running)
            statusProc.running = true;
    }

    function cycle() {
        if (busy)
            return;
        if (mockClass.length > 0) {
            mockClass = mockClass === "quiet" ? "balanced" : mockClass === "balanced" ? "performance" : "quiet";
            return;
        }
        busy = true;
        toggleProc.running = true;
    }

    function mock(cls) {
        mockClass = cls === "quiet" || cls === "balanced" || cls === "performance" ? cls : "";
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: pp.refresh()
    }

    Process {
        id: statusProc
        command: ["/run/current-system/sw/bin/bash", pp.script, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    pp.reported = String(JSON.parse(this.text.trim() || "{}")["class"] || "");
                } catch (e) {
                    pp.reported = "";
                }
            }
        }
    }

    Process {
        id: toggleProc
        command: ["/run/current-system/sw/bin/bash", pp.script, "toggle"]
        onExited: {
            pp.busy = false;
            pp.refresh();
        }
    }
}
