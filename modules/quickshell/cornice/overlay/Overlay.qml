import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.popovers
import qs.sidebar

// Full-screen layer that exists only while something is open. Anything
// drawn here (popover, tray menu, sidebar) sits on top of a click-catcher
// that closes everything; the bar strip is cut out of the input mask so a
// click on another bar button switches surfaces instead of just closing.
PanelWindow {
    id: overlay

    required property var modelData
    readonly property string monitor: modelData ? modelData.name : ""
    readonly property bool active: Panels.anyOpen && Panels.monitor === monitor
    readonly property real margin: Math.round(6 * Theme.s)
    readonly property real top: Theme.barHeight + Math.round(2 * Theme.s)

    // Stay mapped for one fade after closing so the fade-out shows. What was
    // open is latched so the content survives until the window unmaps.
    property bool shown: false
    property string popoverName: ""
    property var menuHandle: null
    property bool sidebarShown: false

    readonly property string livePopover: active ? Panels.popover : ""
    readonly property var liveMenu: active ? Panels.trayMenu : null
    readonly property bool liveSidebar: active && Panels.sidebar

    // Latch on open; on a switch (still active) drop the old one at once,
    // on a close keep it until the unmap timer fires.
    onLivePopoverChanged: if (livePopover.length > 0 || active) popoverName = livePopover
    onLiveMenuChanged: if (liveMenu !== null || active) menuHandle = liveMenu
    onLiveSidebarChanged: if (liveSidebar || active) sidebarShown = liveSidebar

    onActiveChanged: {
        if (active)
            shown = true;
        else
            unmap.restart();
    }

    Timer {
        id: unmap
        interval: 100
        onTriggered: if (!overlay.active) {
            overlay.shown = false;
            overlay.popoverName = "";
            overlay.menuHandle = null;
            overlay.sidebarShown = false;
        }
    }

    screen: modelData
    visible: shown
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "cornice-overlay"
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    mask: Region {
        x: 0
        y: 0
        width: overlay.active ? overlay.width : 0
        height: overlay.active ? overlay.height : 0

        Region {
            intersection: Intersection.Subtract
            x: 0
            y: 0
            width: overlay.width
            height: Theme.barHeight
        }
    }

    function clampX(w) {
        return Math.max(margin, Math.min(Panels.anchorX - w / 2, width - w - margin));
    }

    MouseArea {
        anchors.fill: parent
        enabled: overlay.active
        acceptedButtons: Qt.AllButtons
        onPressed: Panels.closeAll()
    }

    FocusScope {
        anchors.fill: parent
        focus: overlay.active
        Keys.onEscapePressed: Panels.closeAll()

        // Quick fade + a few px of drop on open; closing is instant since
        // the window just goes away.
        opacity: overlay.active ? 1 : 0
        anchors.topMargin: overlay.active ? 0 : -Math.round(6 * Theme.s)

        Behavior on opacity {
            NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
        }

        Behavior on anchors.topMargin {
            NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
        }

        Loader {
            id: popover
            active: overlay.popoverName.length > 0 && overlay.shown
            x: overlay.clampX(width)
            y: overlay.top
            sourceComponent: overlay.popoverName === "calendar" ? calendarPopover
                : overlay.popoverName === "media" ? mediaPopover
                : overlay.popoverName === "network" ? networkPopover
                : overlay.popoverName === "clipboard" ? clipboardPopover
                : overlay.popoverName === "power" ? powerPopover
                : null
            onLoaded: item.forceActiveFocus()
        }

        Loader {
            active: overlay.menuHandle !== null && overlay.shown
            x: overlay.clampX(width)
            y: overlay.top
            sourceComponent: TrayMenu {
                handle: overlay.menuHandle
            }
        }

        Loader {
            active: overlay.sidebarShown && overlay.shown
            anchors.top: parent.top
            anchors.topMargin: overlay.top
            anchors.right: parent.right
            anchors.rightMargin: overlay.margin
            width: Math.min(Math.round(380 * Theme.s), overlay.width - overlay.margin * 2)
            sourceComponent: Sidebar {
                maxHeight: overlay.height - overlay.top - overlay.margin
            }
        }
    }

    Component { id: calendarPopover; CalendarPopover {} }
    Component { id: mediaPopover; MediaPopover {} }
    Component { id: networkPopover; NetworkPopover { maxHeight: overlay.height - overlay.top - overlay.margin } }
    Component { id: clipboardPopover; ClipboardPopover { maxHeight: Math.min(Math.round(520 * Theme.s), overlay.height - overlay.top - overlay.margin) } }
    Component { id: powerPopover; PowerPopover {} }
}
