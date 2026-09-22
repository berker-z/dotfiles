import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.services
import qs.components

// Wi-Fi networks, Bluetooth devices, VPN. Each block is a card with a
// header row (icon, name, state, actions, switch) and a list underneath.
Popover {
    id: pop

    implicitWidth: Math.round(380 * Theme.s)

    property string expandedSsid: ""
    property string password: ""

    readonly property var btAdapter: (typeof Bluetooth !== "undefined" && Bluetooth) ? Bluetooth.defaultAdapter : null
    readonly property bool btOn: btAdapter !== null && btAdapter.enabled
    readonly property var btDevices: {
        var list = (typeof Bluetooth !== "undefined" && Bluetooth && Bluetooth.devices) ? Bluetooth.devices.values.slice() : [];
        function rank(d) {
            if (!d) return 4;
            if (d.connected) return 0;
            if (d.paired) return 1;
            if ((d.deviceName || d.name || "").length > 0) return 2;
            return 3;
        }
        list.sort(function(a, b) {
            var r = rank(a) - rank(b);
            if (r !== 0) return r;
            return String((a && (a.deviceName || a.name)) || "").localeCompare(String((b && (b.deviceName || b.name)) || ""));
        });
        return list.slice(0, 6);
    }
    readonly property int btConnected: btDevices.filter(function(d) { return d && d.connected; }).length

    Component.onCompleted: {
        Wifi.wanted = true;
        Wifi.refresh();
    }
    Component.onDestruction: Wifi.wanted = false

    function btName(d) {
        return d ? (d.deviceName || d.name || d.address || "Unknown device") : "";
    }

    function btMeta(d) {
        if (!d)
            return "";
        var parts = [d.connected ? "Connected" : (d.paired ? "Paired" : "Not paired")];
        if (d.batteryAvailable) {
            var b = d.battery <= 1 ? d.battery * 100 : d.battery;
            if (b > 0)
                parts.push(Math.round(b) + "%");
        }
        return parts.join(" · ");
    }

    Timer {
        id: btScanStop
        interval: 25000
        onTriggered: if (pop.btAdapter) pop.btAdapter.discovering = false
    }

    // ---- Wi-Fi ---------------------------------------------------------------
    Card {
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.gap

            Text {
                text: Wifi.icon
                color: Wifi.enabled ? Theme.accent : Theme.fgMuted
                font.family: Theme.font
                font.pixelSize: Math.round(17 * Theme.s)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: "Wi-Fi"
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text: Wifi.status.length > 0 ? Wifi.status
                        : !Wifi.enabled ? "Off"
                        : Wifi.connected ? Wifi.ssid + " · " + Wifi.signal + "%"
                        : "Not connected"
                    color: Theme.fgMuted
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                }
            }

            Button {
                icon: "󰑓"
                flat: true
                enabled: Wifi.enabled
                onClicked: Wifi.scan()
            }

            Switch {
                checked: Wifi.enabled
                onToggled: Wifi.toggle()
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: Wifi.enabled
            spacing: Math.round(2 * Theme.s)

            Repeater {
                model: Wifi.networks.slice(0, 6)

                ColumnLayout {
                    id: net

                    required property var modelData

                    readonly property bool expanded: pop.expandedSsid === modelData.ssid

                    Layout.fillWidth: true
                    spacing: 0

                    ListRow {
                        Layout.fillWidth: true
                        icon: net.modelData.active ? "󰸞" : (Wifi.secured(net.modelData) ? "󰌾" : "")
                        title: net.modelData.ssid
                        subtitle: net.modelData.active ? "Connected" : (Wifi.secured(net.modelData) ? net.modelData.security : "Open")
                        trailingText: net.modelData.signal + "%"
                        selected: net.modelData.active
                        highlighted: net.expanded
                        onClicked: {
                            if (net.modelData.active) {
                                Wifi.disconnect();
                            } else if (Wifi.secured(net.modelData)) {
                                pop.expandedSsid = net.expanded ? "" : net.modelData.ssid;
                                pop.password = "";
                            } else {
                                Wifi.connect(net.modelData.ssid, "");
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Math.round(10 * Theme.s)
                        Layout.rightMargin: Math.round(10 * Theme.s)
                        Layout.topMargin: Math.round(4 * Theme.s)
                        Layout.bottomMargin: Math.round(6 * Theme.s)
                        visible: net.expanded
                        spacing: Theme.gap

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.controlHeight
                            radius: Theme.controlRadius
                            color: Theme.shell
                            border.width: 1
                            border.color: input.activeFocus ? Theme.accent : Theme.border

                            TextInput {
                                id: input
                                anchors.fill: parent
                                anchors.leftMargin: Math.round(10 * Theme.s)
                                anchors.rightMargin: Math.round(10 * Theme.s)
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: TextInput.Password
                                color: Theme.fg
                                selectionColor: Theme.accentStrong
                                selectedTextColor: Theme.fg
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                                clip: true
                                onTextEdited: pop.password = text
                                onAccepted: Wifi.connect(net.modelData.ssid, pop.password)
                                Component.onCompleted: if (net.expanded) forceActiveFocus()
                            }

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: Math.round(10 * Theme.s)
                                verticalAlignment: Text.AlignVCenter
                                visible: input.text.length === 0
                                text: "Password (empty = use saved)"
                                color: Theme.alpha(Theme.fgMuted, 0.6)
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                            }
                        }

                        Button {
                            label: "Join"
                            icon: "󰌘"
                            onClicked: Wifi.connect(net.modelData.ssid, pop.password)
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.margins: Math.round(8 * Theme.s)
                visible: Wifi.networks.length === 0
                text: "No networks found"
                color: Theme.fgMuted
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
        }
    }

    // ---- Bluetooth -------------------------------------------------------------
    Card {
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.gap

            Text {
                text: pop.btOn ? (pop.btConnected > 0 ? "󰂱" : "󰂯") : "󰂲"
                color: pop.btOn ? Theme.accent : Theme.fgMuted
                font.family: Theme.font
                font.pixelSize: Math.round(17 * Theme.s)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: "Bluetooth"
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text: !pop.btAdapter ? "No adapter"
                        : !pop.btOn ? "Off"
                        : pop.btAdapter.discovering ? "Scanning…"
                        : pop.btConnected > 0 ? pop.btConnected + " connected"
                        : "Not connected"
                    color: Theme.fgMuted
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                }
            }

            Button {
                icon: "󰑓"
                flat: true
                enabled: pop.btOn
                active: pop.btOn && pop.btAdapter.discovering
                onClicked: {
                    pop.btAdapter.discovering = !pop.btAdapter.discovering;
                    if (pop.btAdapter.discovering)
                        btScanStop.restart();
                    else
                        btScanStop.stop();
                }
            }

            Switch {
                checked: pop.btOn
                enabled: pop.btAdapter !== null
                onToggled: if (pop.btAdapter) pop.btAdapter.enabled = !pop.btAdapter.enabled
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: pop.btOn
            spacing: Math.round(2 * Theme.s)

            Repeater {
                model: pop.btDevices

                ListRow {
                    required property var modelData

                    Layout.fillWidth: true
                    icon: modelData.connected ? "󰸞" : "󰂯"
                    title: pop.btName(modelData)
                    subtitle: pop.btMeta(modelData)
                    trailingText: modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair")
                    selected: modelData.connected
                    onClicked: {
                        if (modelData.connected)
                            modelData.disconnect();
                        else if (modelData.paired)
                            modelData.connect();
                        else
                            modelData.pair();
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.margins: Math.round(8 * Theme.s)
                visible: pop.btDevices.length === 0
                text: pop.btAdapter && pop.btAdapter.discovering ? "Searching…" : "No devices"
                color: Theme.fgMuted
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
        }
    }

    // ---- VPN -------------------------------------------------------------------
    Card {
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.gap

            Text {
                text: "󰦝"
                color: Status.vpn ? Theme.accent : Theme.fgMuted
                font.family: Theme.font
                font.pixelSize: Math.round(17 * Theme.s)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: "Frankfurt exit"
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text: !Status.exitNodeAvailable ? "Needs approval" : (Status.vpnBusy ? "Switching…" : (Status.vpn ? "Tailscale on" : "Off"))
                    color: Theme.fgMuted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                }
            }

            Switch {
                checked: Status.vpn
                enabled: Status.exitNodeAvailable && !Status.vpnBusy
                onToggled: Status.toggleVpn()
            }
        }
    }
}
