import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.services
import qs.components
import qs.popovers

// Control centre. Only things that are not one click away on the bar:
// the toggle grid, sliders, now playing, notifications, theme.
Rectangle {
    id: side

    readonly property var btAdapter: (typeof Bluetooth !== "undefined" && Bluetooth) ? Bluetooth.defaultAdapter : null
    readonly property bool btOn: btAdapter !== null && btAdapter.enabled
    readonly property int btConnected: {
        var list = (typeof Bluetooth !== "undefined" && Bluetooth && Bluetooth.devices) ? Bluetooth.devices.values : [];
        var n = 0;
        for (var i = 0; i < list.length; i++)
            if (list[i] && list[i].connected)
                n++;
        return n;
    }

    property real maxHeight: 0

    implicitHeight: Math.min(maxHeight > 0 ? maxHeight : 1e9, content.implicitHeight + Theme.pad * 2)
    radius: Theme.popoverRadius
    color: Theme.surface
    border.width: 1
    border.color: Theme.border
    clip: true

    Component.onCompleted: Notifs.refresh()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: Theme.pad
        contentHeight: content.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        ColumnLayout {
            id: content
            width: parent.width
            spacing: Theme.pad

            Header {
                Layout.fillWidth: true
                title: "Control centre"
                subtitle: Qt.formatDateTime(new Date(), "dddd, d MMMM") + (Battery.present ? "  ·  " + Battery.icon + " " + Battery.percent + "%, " + Battery.timeText : "")

                Button {
                    icon: "󰅖"
                    flat: true
                    onClicked: Panels.closeAll()
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: Theme.gap
                columnSpacing: Theme.gap

                Toggle {
                    Layout.fillWidth: true
                    icon: Wifi.icon
                    label: "Wi-Fi"
                    checked: Wifi.enabled
                    stateText: Wifi.enabled ? (Wifi.ssid.length > 0 ? Wifi.ssid : "On") : "Off"
                    onClicked: Wifi.toggle()
                }

                Toggle {
                    Layout.fillWidth: true
                    icon: side.btOn ? "󰂯" : "󰂲"
                    label: "Bluetooth"
                    checked: side.btOn
                    enabled: side.btAdapter !== null
                    stateText: !side.btOn ? "Off" : (side.btConnected > 0 ? side.btConnected + " connected" : "On")
                    onClicked: if (side.btAdapter) side.btAdapter.enabled = !side.btAdapter.enabled
                }

                Toggle {
                    Layout.fillWidth: true
                    icon: "󰦝"
                    label: "VPN"
                    checked: Status.vpn
                    busy: Status.vpnBusy
                    stateText: Status.vpn ? "wg0 up" : "Off"
                    onClicked: Status.toggleVpn()
                }

                Toggle {
                    Layout.fillWidth: true
                    icon: Status.dnd ? "󰂛" : "󰂚"
                    label: "Do not disturb"
                    checked: Status.dnd
                    onClicked: Status.toggleDnd()
                }

                Toggle {
                    Layout.fillWidth: true
                    icon: "󰅶"
                    label: "Keep awake"
                    checked: Status.keepAwake
                    stateText: Status.keepAwake ? "Idle blocked" : "Off"
                    onClicked: Status.toggleKeepAwake()
                }

                Toggle {
                    Layout.fillWidth: true
                    icon: Audio.micMuted ? "󰍭" : "󰍬"
                    label: "Microphone"
                    checked: !Audio.micMuted
                    enabled: Audio.sourceReady
                    stateText: Audio.micMuted ? "Muted" : Audio.micPct + "%"
                    onClicked: Audio.toggleMicMute()
                }
            }

            Card {
                padding: Theme.pad
                AudioControls { Layout.fillWidth: true }
            }

            Card {
                padding: Theme.pad
                NowPlaying { Layout.fillWidth: true }
            }

            Header {
                Layout.fillWidth: true
                title: "Notifications"
                subtitle: Notifs.count === 0 ? "Nothing new" : Notifs.count + (Notifs.count === 1 ? " item" : " items")

                Button {
                    icon: "󰆴"
                    flat: true
                    danger: true
                    enabled: Notifs.count > 0
                    onClicked: Notifs.dismissAll()
                }

                Button {
                    icon: Panels.notifsCollapsed ? "󰅀" : "󰅃"
                    flat: true
                    onClicked: Panels.notifsCollapsed = !Panels.notifsCollapsed
                }
            }

            NotificationList {
                Layout.fillWidth: true
                visible: !Panels.notifsCollapsed
            }

            Header {
                Layout.fillWidth: true
                title: "Theme"
                subtitle: Theme.options.find(function(o) { return o.id === Theme.name; }).label
            }

            ThemePicker {
                Layout.fillWidth: true
            }
        }
    }
}
