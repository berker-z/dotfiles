import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs
import qs.services
import qs.components

// The strip itself: a real layer-shell panel with an exclusive zone. Three
// islands; the media island appears next to the left one when something is
// playing. Popovers are not here — they live in the Overlay window.
PanelWindow {
    id: bar

    required property var modelData
    readonly property string monitor: modelData ? modelData.name : ""

    screen: modelData
    color: "transparent"
    implicitHeight: Theme.barHeight
    exclusiveZone: Panels.barHidden ? 0 : Theme.barHeight
    visible: !Panels.barHidden
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "cornice-bar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
    }

    readonly property string windowLabel: {
        var top = Hyprland.activeToplevel;
        if (!top)
            return "desktop";
        var ipc = top.lastIpcObject || {};
        var label = ipc.initialClass || ipc["class"] || top.title || "";
        return label.length > 0 ? label : "desktop";
    }

    readonly property bool laptopItems: Battery.present || PowerProfile.present

    function open(name, item) {
        var p = item.mapToItem(null, item.width / 2, 0);
        Panels.togglePopover(bar.monitor, name, p.x);
    }

    function popoverOpen(name) {
        return Panels.popover === name && Panels.monitor === bar.monitor;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Math.round(6 * Theme.s)
        anchors.rightMargin: Math.round(6 * Theme.s)

        // ---- left: launcher, workspaces, focused window, media -------------
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: Math.round(6 * Theme.s)

            Island {
                Button {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "󰀻"
                    flat: true
                    size: Math.round(24 * Theme.s)
                    onClicked: {
                        Panels.closeAll();
                        Quickshell.execDetached(["fuzzel"]);
                    }
                }

                Workspaces {
                    monitor: bar.monitor
                }

                Item { width: Math.round(2 * Theme.s); height: 1 }
            }

            // Media island: [volume] [state glyph] [artist — title].
            // Left click on the title toggles play/pause, wheel on it skips
            // tracks, wheel on the slider is volume, right click anywhere
            // opens the media popover. The slider sits first so it never
            // moves when the title changes width.
            Island {
                id: mediaIsland
                visible: Media.active && Media.label.length > 0
                highlighted: bar.popoverOpen("media")
                padding: Math.round(10 * Theme.s)
                onRightClicked: bar.open("media", mediaIsland)

                Slider {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.round(80 * Theme.s)
                    height: Math.round(20 * Theme.s)
                    handle: false
                    value: Audio.volume
                    muted: Audio.muted
                    enabled: Audio.sinkReady
                    onMoved: function(v) { Audio.setVolume(v); }
                    onMiddleClicked: Audio.toggleMute()
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: Math.round(8 * Theme.s)
                    rightPadding: Math.round(6 * Theme.s)
                    text: Media.playing ? "󰎇" : "󰏤"
                    color: Media.playing ? Theme.accent : Theme.fgMuted
                    font.family: Theme.font
                    font.pixelSize: Theme.iconSize
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(Math.round(260 * Theme.s), implicitWidth)
                    text: Media.label
                    color: Media.playing ? Theme.fg : Theme.fgMuted
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton)
                                bar.open("media", mediaIsland);
                            else
                                Media.toggle();
                        }
                        onWheel: function(w) {
                            if (w.angleDelta.y > 0)
                                Media.previous();
                            else
                                Media.next();
                        }
                    }
                }
            }
        }

        // ---- centre: clock :: date :: title ---------------------------------
        // The clock+date part is pinned to the screen centre; the island only
        // ever grows to the right as the title changes, so nothing jumps.
        Island {
            id: clockIsland
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width / 2 - padding - (clockText.implicitWidth + sep1.implicitWidth + dateText.implicitWidth) / 2
            highlighted: bar.popoverOpen("calendar")
            padding: Math.round(12 * Theme.s)
            onClicked: bar.open("calendar", clockIsland)

            component Sep: Text {
                anchors.verticalCenter: parent.verticalCenter
                text: " :: "
                color: Theme.alpha(Theme.fgMuted, 0.6)
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }

            Text {
                id: clockText
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatTime(clock.date, "HH:mm:ss")
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                font.features: { "tnum": 1 }
            }

            Sep { id: sep1 }

            Text {
                id: dateText
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDate(clock.date, "ddd d MMM")
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }

            Sep {}

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(Math.round(320 * Theme.s), implicitWidth)
                text: bar.windowLabel
                color: Theme.fg
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
        }

        // ---- right: battery, status, tray, network, audio, clipboard, centre, power ----
        Island {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(2 * Theme.s)
                visible: Status.vpn || Status.dnd || Status.keepAwake

                Button {
                    visible: Status.vpn
                    icon: "󰦝"
                    flat: true
                    tooltip: "VPN on"
                    size: Math.round(24 * Theme.s)
                    onClicked: Status.toggleVpn()
                }

                Button {
                    visible: Status.dnd
                    icon: "󰂛"
                    flat: true
                    size: Math.round(24 * Theme.s)
                    onClicked: Status.toggleDnd()
                }

                Button {
                    visible: Status.keepAwake
                    icon: "󰅶"
                    flat: true
                    size: Math.round(24 * Theme.s)
                    onClicked: Status.toggleKeepAwake()
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: Math.round(14 * Theme.s)
                    color: Theme.border
                }
            }

            Button {
                id: networkButton
                anchors.verticalCenter: parent.verticalCenter
                icon: Wifi.icon
                flat: true
                active: bar.popoverOpen("network")
                size: Math.round(24 * Theme.s)
                onClicked: bar.open("network", networkButton)
            }

            Button {
                id: audioButton
                anchors.verticalCenter: parent.verticalCenter
                icon: Audio.icon
                label: Audio.volumePct + "%"
                flat: true
                active: bar.popoverOpen("media")
                size: Math.round(24 * Theme.s)
                labelSize: Theme.fontSmall
                onClicked: function(mouse) {
                    if (mouse.button === Qt.MiddleButton)
                        Audio.toggleMute();
                    else
                        bar.open("media", audioButton);
                }
                onWheel: function(w) { Audio.step(w.angleDelta.y > 0 ? 0.05 : -0.05); }
            }

            Rectangle {
                visible: bar.laptopItems || tray.visible
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: Math.round(14 * Theme.s)
                color: Theme.border
            }

            // Laptop only: neither service reports `present` without a
            // battery / an ASUS platform profile.
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(2 * Theme.s)
                visible: bar.laptopItems

                Button {
                    property bool showTime: false
                    visible: Battery.present
                    anchors.verticalCenter: parent.verticalCenter
                    icon: Battery.icon
                    label: showTime ? Battery.timeText : Battery.percent + "%"
                    flat: true
                    tint: Battery.critical ? Theme.red : Battery.warning ? Theme.yellow : Battery.plugged ? Theme.green : "transparent"
                    size: Math.round(24 * Theme.s)
                    labelSize: Theme.fontSmall
                    onClicked: showTime = !showTime
                }

                Button {
                    visible: PowerProfile.present
                    anchors.verticalCenter: parent.verticalCenter
                    icon: PowerProfile.icon
                    label: PowerProfile.label
                    flat: true
                    enabled: !PowerProfile.busy
                    size: Math.round(24 * Theme.s)
                    labelSize: Theme.fontSmall
                    onClicked: PowerProfile.cycle()
                }

                Rectangle {
                    visible: tray.visible
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: Math.round(14 * Theme.s)
                    color: Theme.border
                }
            }

            Tray {
                id: tray
                monitor: bar.monitor
            }

            Rectangle {
                visible: Battery.present || tray.visible
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: Math.round(14 * Theme.s)
                color: Theme.border
            }

            Button {
                id: clipButton
                anchors.verticalCenter: parent.verticalCenter
                icon: "󰅌"
                flat: true
                active: bar.popoverOpen("clipboard")
                size: Math.round(24 * Theme.s)
                onClicked: bar.open("clipboard", clipButton)
            }

            Button {
                anchors.verticalCenter: parent.verticalCenter
                icon: "󰍜"
                flat: true
                active: Panels.sidebar && Panels.monitor === bar.monitor
                size: Math.round(24 * Theme.s)
                onClicked: Panels.toggleSidebar(bar.monitor)
            }

            Button {
                id: powerButton
                anchors.verticalCenter: parent.verticalCenter
                icon: "⏻"
                flat: true
                active: bar.popoverOpen("power")
                size: Math.round(24 * Theme.s)
                onClicked: bar.open("power", powerButton)
            }
        }
    }
}
