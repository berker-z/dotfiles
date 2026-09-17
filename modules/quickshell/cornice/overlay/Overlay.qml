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

    screen: modelData
    visible: active
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
        width: overlay.width
        height: overlay.height

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
        acceptedButtons: Qt.AllButtons
        onPressed: Panels.closeAll()
    }

    FocusScope {
        anchors.fill: parent
        focus: overlay.active
        Keys.onEscapePressed: Panels.closeAll()

        Loader {
            id: popover
            active: Panels.popover.length > 0 && overlay.active
            x: overlay.clampX(width)
            y: overlay.top
            sourceComponent: Panels.popover === "calendar" ? calendarPopover
                : Panels.popover === "media" ? mediaPopover
                : Panels.popover === "network" ? networkPopover
                : Panels.popover === "clipboard" ? clipboardPopover
                : Panels.popover === "power" ? powerPopover
                : null
            onLoaded: item.forceActiveFocus()
        }

        Loader {
            active: Panels.trayMenu !== null && overlay.active
            x: overlay.clampX(width)
            y: overlay.top
            sourceComponent: TrayMenu {
                handle: Panels.trayMenu
            }
        }

        Loader {
            active: Panels.sidebar && overlay.active
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
