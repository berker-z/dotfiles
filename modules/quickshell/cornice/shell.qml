import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services
import qs.bar
import qs.overlay

// Entry point. State lives in the singletons under services/; this file
// only instantiates the per-screen windows and exposes the IPC surface the
// cornice wrapper script talks to.
ShellRoot {
    id: root

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            switch (event.name) {
            case "workspace":
            case "workspacev2":
            case "createworkspace":
            case "destroyworkspace":
            case "focusedmon":
            case "focusedmonv2":
            case "movewindow":
            case "closewindow":
            case "openwindow":
            case "activewindow":
            case "activewindowv2":
            case "monitoradded":
            case "monitorremoved":
                Hyprland.refreshMonitors();
                Hyprland.refreshWorkspaces();
                Hyprland.refreshToplevels();
                break;
            }
        }
    }

    IpcHandler {
        target: "bar"

        function ping(): void {}

        function toggle(mon: string, surface: string): void {
            var name = surface === "links" ? "network"
                : surface === "mixer" || surface === "audio" ? "media"
                : surface;
            if (name === "theme") {
                Panels.toggleSidebar(mon);
                return;
            }
            var screens = Quickshell.screens;
            var w = 0;
            for (var i = 0; i < screens.length; i++)
                if (screens[i].name === mon)
                    w = screens[i].width;
            // Keyboard-opened popovers hang under the middle of the right
            // island; the calendar under the clock.
            var x = name === "calendar" ? w / 2 : w - Math.round(120 * Theme.s);
            Panels.togglePopover(mon, name, x);
        }

        function peek(mon: string): void {
            Panels.toggleBar();
        }

        function hide(): void {
            Panels.closeAll();
        }

        function sidebar(mon: string): void {
            Panels.toggleSidebar(mon);
        }

        function dnd(): void {
            Status.toggleDnd();
        }

        function awake(): void {
            Status.toggleKeepAwake();
        }

        // `qs -c cornice ipc call bar battery 42 discharging` — preview the
        // battery item on a machine without one; percent "off" removes it.
        function battery(pct: string, state: string): void {
            Battery.mock(pct, state);
        }
    }

    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Variants {
        model: Quickshell.screens
        Overlay {}
    }

    PanelWindow {
        id: inhibitWin

        visible: Status.keepAwake
        implicitWidth: 1
        implicitHeight: 1
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "cornice-inhibit"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            left: true
        }

        IdleInhibitor {
            window: inhibitWin
            enabled: Status.keepAwake
        }
    }
}
