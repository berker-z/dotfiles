pragma Singleton

import QtQuick
import Quickshell

// Which overlay surface is open, on which monitor, and where it should be
// anchored. Exactly one thing can be open at a time; opening anything closes
// whatever was open before, and closeAll() is the single exit path used by
// click-outside, Escape and the IPC hide call.
Singleton {
    id: panels

    property string monitor: ""
    property string popover: ""
    property real anchorX: 0
    property bool sidebar: false
    property var trayMenu: null
    property bool barHidden: false
    property bool notifsCollapsed: false

    readonly property bool anyOpen: popover.length > 0 || sidebar || trayMenu !== null

    function closeAll() {
        popover = "";
        sidebar = false;
        trayMenu = null;
    }

    function openPopover(mon, name, x) {
        closeAll();
        monitor = mon;
        anchorX = x;
        popover = name;
    }

    function togglePopover(mon, name, x) {
        if (popover === name && monitor === mon) {
            closeAll();
            return;
        }
        openPopover(mon, name, x);
    }

    function openTrayMenu(mon, menu, x) {
        closeAll();
        monitor = mon;
        anchorX = x;
        trayMenu = menu;
    }

    function toggleSidebar(mon) {
        if (sidebar && monitor === mon) {
            closeAll();
            return;
        }
        closeAll();
        monitor = mon;
        sidebar = true;
    }

    function toggleBar() {
        closeAll();
        barHidden = !barHidden;
    }
}
