pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Wayland

ShellRoot {
    id: root

    property string openMon: ""
    property string openSurface: ""
    property string peekMon: ""
    property bool sidebarShown: false
    property string sidebarMon: ""
    property bool keepAwake: false
    property string activeWindowLabel: "desktop"

    readonly property color nord0: "#2e3440"
    readonly property color nord1: "#3b4252"
    readonly property color nord2: "#434c5e"
    readonly property color nord3: "#4c566a"
    readonly property color nord4: "#d8dee9"
    readonly property color nord5: "#e5e9f0"
    readonly property color nord6: "#eceff4"
    readonly property color nord7: "#8fbcbb"
    readonly property color nord8: "#88c0d0"
    readonly property color nord9: "#81a1c1"
    readonly property color nord10: "#5e81ac"
    readonly property color nord11: "#bf616a"
    readonly property color nord12: "#d08770"
    readonly property color nord13: "#ebcb8b"
    readonly property color nord14: "#a3be8c"
    readonly property color nord15: "#b48ead"
    readonly property string uiFont: "Iosevka Nerd Font"
    readonly property string iconFont: "Font Awesome 6 Free"

    function refresh() {
        Hyprland.refreshMonitors();
        Hyprland.refreshWorkspaces();
        Hyprland.refreshToplevels();
    }

    function toggle(mon, surface) {
        if (root.openMon === mon && root.openSurface === surface) {
            root.close();
            return;
        }
        root.openMon = mon;
        root.openSurface = surface;
        root.peekMon = mon;
    }

    function close() {
        root.openMon = "";
        root.openSurface = "";
    }

    function togglePeek(mon) {
        if (root.peekMon === mon && root.openSurface === "") {
            root.peekMon = "";
        } else {
            root.peekMon = mon;
            root.close();
        }
    }

    function hideAll() {
        root.peekMon = "";
        root.close();
        root.sidebarShown = false;
    }

    function toggleSidebar(mon) {
        if (root.sidebarShown && (root.sidebarMon === "" || root.sidebarMon === mon)) {
            root.sidebarShown = false;
            return;
        }
        root.sidebarMon = mon;
        root.sidebarShown = true;
        root.peekMon = "";
        root.close();
    }

    function run(command) {
        Quickshell.execDetached(["sh", "-c", command]);
    }

    function toggleDnd() {
        root.run("makoctl mode 2>/dev/null | grep -q dnd && makoctl mode -r dnd || makoctl mode -a dnd");
    }

    function thumbPath(id) {
        return (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache"))
            + "/nord-pill/cliphist-thumbs/" + id + ".png";
    }

    function refreshActiveWindow() {
        if (!activeWindowProc.running)
            activeWindowProc.running = true;
    }

    Component.onCompleted: {
        refresh();
        refreshActiveWindow();
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if ({
                workspace: true,
                workspacev2: true,
                createworkspace: true,
                destroyworkspace: true,
                focusedmon: true,
                focusedmonv2: true,
                movewindow: true,
                closewindow: true,
                openwindow: true,
                activewindow: true,
                activewindowv2: true,
                monitoradded: true,
                monitorremoved: true
            }[event.name]) {
                root.refresh();
                root.refreshActiveWindow();
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refreshActiveWindow()
    }

    Process {
        id: activeWindowProc
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                var label = "desktop";
                try {
                    var window = JSON.parse(this.text.trim() || "{}");
                    label = window.initialClass || window.class || window.title || "desktop";
                } catch (e) {
                    label = "desktop";
                }
                root.activeWindowLabel = label.length > 0 && label !== "null" ? label : "desktop";
            }
        }
    }

    IpcHandler {
        target: "pill"

        function ping(): void {}

        function peek(mon: string): void {
            root.togglePeek(mon);
        }

        function toggle(mon: string, surface: string): void {
            root.toggle(mon, surface);
        }

        function hide(): void {
            root.hideAll();
        }

        function sidebar(mon: string): void {
            root.toggleSidebar(mon);
        }

    }

    component ActionButton: Rectangle {
        id: button

        property string icon: ""
        property string label: ""
        property bool active: false
        property real scaleFactor: 1

        signal activated()

        implicitWidth: Math.max(74 * scaleFactor, content.implicitWidth + 24 * scaleFactor)
        implicitHeight: 36 * scaleFactor
        radius: 7 * scaleFactor
        color: active ? root.nord10 : (area.containsMouse ? root.nord2 : root.nord1)
        border.width: 1
        border.color: active ? root.nord8 : root.nord3

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Row {
            id: content
            anchors.centerIn: parent
            spacing: 7 * button.scaleFactor

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: button.icon
                color: button.active ? root.nord6 : root.nord8
                font.family: root.uiFont
                font.pixelSize: 14 * button.scaleFactor
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: button.label
                color: root.nord6
                font.family: root.uiFont
                font.pixelSize: 13 * button.scaleFactor
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.activated()
        }
    }

    component IconButton: Rectangle {
        id: button

        property string icon: ""
        property string label: ""
        property bool active: false
        property real scaleFactor: 1

        signal activated()

        width: 38 * scaleFactor
        height: 32 * scaleFactor
        radius: 7 * scaleFactor
        color: active ? root.nord10 : (area.containsMouse ? root.nord2 : "transparent")
        border.width: area.containsMouse || active ? 1 : 0
        border.color: active ? root.nord8 : root.nord3

        Text {
            anchors.centerIn: parent
            text: button.icon
            color: button.active ? root.nord6 : root.nord5
            font.family: root.uiFont
            font.pixelSize: 15 * button.scaleFactor
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.activated()
        }
    }

    component ToggleSwitch: Rectangle {
        id: toggle

        property bool checked: false
        property real scaleFactor: 1

        signal toggled()

        width: 44 * scaleFactor
        height: 24 * scaleFactor
        radius: 7 * scaleFactor
        color: checked ? root.nord10 : root.nord0
        border.width: 1
        border.color: checked ? root.nord8 : root.nord3

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Rectangle {
            width: 16 * toggle.scaleFactor
            height: 16 * toggle.scaleFactor
            radius: 5 * toggle.scaleFactor
            x: toggle.checked ? toggle.width - width - 4 * toggle.scaleFactor : 4 * toggle.scaleFactor
            anchors.verticalCenter: parent.verticalCenter
            color: toggle.checked ? root.nord6 : root.nord4

            Behavior on x {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: toggle.toggled()
        }
    }

    component SectionTitle: Column {
        id: title

        property string overline: ""
        property string heading: ""
        property real scaleFactor: 1

        spacing: 3 * scaleFactor

        Text {
            text: title.overline
            color: root.nord8
            font.family: root.uiFont
            font.pixelSize: 11 * title.scaleFactor
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
        }

        Text {
            width: title.width
            text: title.heading
            color: root.nord6
            elide: Text.ElideRight
            font.family: root.uiFont
            font.pixelSize: 17 * title.scaleFactor
            font.weight: Font.Bold
        }
    }

    component TrayMenuRow: Item {
        id: menuRow

        property var entryData
        property real indent: 0
        property real scaleFactor: 1
        property bool expanded: false

        signal activated()

        height: entryData && entryData.isSeparator ? 8 * scaleFactor : 32 * scaleFactor

        Rectangle {
            visible: menuRow.entryData && menuRow.entryData.isSeparator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8 * menuRow.scaleFactor + menuRow.indent
            anchors.rightMargin: 8 * menuRow.scaleFactor
            height: 1
            color: root.nord3
        }

        Rectangle {
            visible: menuRow.entryData && !menuRow.entryData.isSeparator
            anchors.fill: parent
            anchors.leftMargin: menuRow.indent
            radius: 6 * menuRow.scaleFactor
            color: menuRowMouse.containsMouse && menuRow.entryData.enabled ? root.nord2 : "transparent"

            Rectangle {
                id: stateMark

                readonly property bool isCheck: menuRow.entryData && menuRow.entryData.buttonType === QsMenuButtonType.CheckBox
                readonly property bool isRadio: menuRow.entryData && menuRow.entryData.buttonType === QsMenuButtonType.RadioButton
                readonly property bool present: isCheck || isRadio
                readonly property bool checked: menuRow.entryData && menuRow.entryData.checkState === Qt.Checked

                visible: present
                anchors.left: parent.left
                anchors.leftMargin: 9 * menuRow.scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                width: 12 * menuRow.scaleFactor
                height: 12 * menuRow.scaleFactor
                radius: isRadio ? width / 2 : 3 * menuRow.scaleFactor
                color: checked ? root.nord8 : "transparent"
                border.width: 1
                border.color: checked ? root.nord8 : root.nord3
            }

            Image {
                id: menuIcon

                anchors.left: parent.left
                anchors.leftMargin: stateMark.present ? 27 * menuRow.scaleFactor : 9 * menuRow.scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                width: menuRow.entryData && menuRow.entryData.icon ? 15 * menuRow.scaleFactor : 0
                height: 15 * menuRow.scaleFactor
                source: menuRow.entryData && menuRow.entryData.icon ? menuRow.entryData.icon : ""
                sourceSize.width: 30
                sourceSize.height: 30
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: source.toString().length > 0
            }

            Text {
                anchors.left: menuIcon.visible ? menuIcon.right : parent.left
                anchors.leftMargin: menuIcon.visible ? 8 * menuRow.scaleFactor : (stateMark.present ? 27 * menuRow.scaleFactor : 9 * menuRow.scaleFactor)
                anchors.right: chevron.visible ? chevron.left : parent.right
                anchors.rightMargin: 10 * menuRow.scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                text: menuRow.entryData ? menuRow.entryData.text : ""
                color: !menuRow.entryData || !menuRow.entryData.enabled ? root.nord3 : (menuRowMouse.containsMouse ? root.nord6 : root.nord4)
                elide: Text.ElideRight
                font.family: root.uiFont
                font.pixelSize: 12 * menuRow.scaleFactor
                font.weight: menuRowMouse.containsMouse ? Font.DemiBold : Font.Normal
            }

            Text {
                id: chevron

                anchors.right: parent.right
                anchors.rightMargin: 9 * menuRow.scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                visible: menuRow.entryData && menuRow.entryData.hasChildren
                text: menuRow.expanded ? "⌄" : "›"
                color: root.nord8
                font.family: root.uiFont
                font.pixelSize: 14 * menuRow.scaleFactor
                font.weight: Font.Bold
            }

            MouseArea {
                id: menuRowMouse

                anchors.fill: parent
                hoverEnabled: true
                enabled: menuRow.entryData && menuRow.entryData.enabled
                cursorShape: Qt.PointingHandCursor
                onClicked: menuRow.activated()
            }
        }
    }

    component TrayStrip: Item {
        id: tray

        property real scaleFactor: 1
        property var hostWindow
        property real menuTop: 64 * scaleFactor
        property real maxStripWidth: 180 * scaleFactor
        property bool expandedRows: false

        readonly property var items: SystemTray.items.values
        readonly property int itemCount: items.length

        visible: itemCount > 0
        width: visible ? Math.min(maxStripWidth, row.implicitWidth) : 0
        height: row.implicitHeight
        clip: true
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        function showMenu(item, anchorItem) {
            if (!item || !item.hasMenu)
                return;
            menuCard.expandedIdx = -1;
            opener.menu = item.menu;
            var p = anchorItem.mapToItem(null, anchorItem.width / 2, anchorItem.height);
            menu.anchorX = p.x;
            menu.open = true;
        }

        QsMenuOpener {
            id: opener
        }

        RowLayout {
            id: row

            spacing: 5 * tray.scaleFactor

            Repeater {
                model: SystemTray.items

                delegate: Rectangle {
                    id: slot

                    required property var modelData

                    Layout.preferredWidth: tray.expandedRows ? 32 * tray.scaleFactor : 30 * tray.scaleFactor
                    Layout.preferredHeight: tray.expandedRows ? 32 * tray.scaleFactor : 30 * tray.scaleFactor
                    radius: 7 * tray.scaleFactor
                    color: trayMouse.containsMouse ? root.nord2 : Qt.rgba(root.nord0.r, root.nord0.g, root.nord0.b, 0.45)
                    border.width: 1
                    border.color: trayMouse.containsMouse ? root.nord8 : root.nord3

                    Image {
                        id: trayIcon

                        anchors.centerIn: parent
                        width: 18 * tray.scaleFactor
                        height: 18 * tray.scaleFactor
                        source: slot.modelData && slot.modelData.icon ? slot.modelData.icon : ""
                        sourceSize.width: 36
                        sourceSize.height: 36
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        smooth: true
                        mipmap: true
                        visible: source.toString().length > 0
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !trayIcon.visible
                        text: "•"
                        color: root.nord8
                        font.family: root.uiFont
                        font.pixelSize: 16 * tray.scaleFactor
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: trayMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: function(mouse) {
                            if (!slot.modelData)
                                return;
                            if (mouse.button === Qt.RightButton) {
                                tray.showMenu(slot.modelData, slot);
                            } else if (mouse.button === Qt.MiddleButton && typeof slot.modelData.secondaryActivate === "function") {
                                slot.modelData.secondaryActivate();
                            } else if (slot.modelData.onlyMenu) {
                                tray.showMenu(slot.modelData, slot);
                            } else if (typeof slot.modelData.activate === "function") {
                                slot.modelData.activate();
                            }
                        }
                        onWheel: function(wheel) {
                            if (slot.modelData && typeof slot.modelData.scroll === "function")
                                slot.modelData.scroll(wheel.angleDelta.y, false);
                        }
                    }
                }
            }
        }

        PanelWindow {
            id: menu

            property bool open: false
            property real anchorX: 0

            screen: tray.hostWindow ? tray.hostWindow.screen : null
            visible: open
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "nord-pill-tray"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            onOpenChanged: if (!open) {
                menuCard.expandedIdx = -1;
                opener.menu = null;
            }

            MouseArea {
                anchors.fill: parent
                onClicked: menu.open = false
            }

            FocusScope {
                anchors.fill: parent
                focus: menu.open
                Keys.onEscapePressed: menu.open = false

                Rectangle {
                    id: menuCard

                    property int expandedIdx: -1

                    x: Math.max(8 * tray.scaleFactor, Math.min(menu.anchorX - width / 2, menu.width - width - 8 * tray.scaleFactor))
                    y: tray.menuTop
                    width: 230 * tray.scaleFactor
                    height: Math.min(menu.height - y - 10 * tray.scaleFactor, menuContent.implicitHeight + 12 * tray.scaleFactor)
                    radius: 8 * tray.scaleFactor
                    color: Qt.rgba(root.nord1.r, root.nord1.g, root.nord1.b, 0.98)
                    border.width: 1
                    border.color: root.nord8
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                    }

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 6 * tray.scaleFactor
                        contentHeight: menuContent.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        Column {
                            id: menuContent

                            width: parent.width
                            spacing: 1 * tray.scaleFactor

                            Repeater {
                                model: opener.children ? opener.children.values : []

                                delegate: Column {
                                    id: entry

                                    required property var modelData
                                    required property int index

                                    readonly property bool rowExpanded: menuCard.expandedIdx === index

                                    width: menuContent.width

                                    TrayMenuRow {
                                        width: parent.width
                                        entryData: entry.modelData
                                        expanded: entry.rowExpanded
                                        scaleFactor: tray.scaleFactor
                                        onActivated: {
                                            if (entry.modelData.hasChildren) {
                                                menuCard.expandedIdx = entry.rowExpanded ? -1 : entry.index;
                                            } else {
                                                entry.modelData.triggered();
                                                menu.open = false;
                                            }
                                        }
                                    }

                                    QsMenuOpener {
                                        id: childOpener
                                        menu: entry.rowExpanded ? entry.modelData : null
                                    }

                                    Repeater {
                                        model: childOpener.children ? childOpener.children.values : []

                                        delegate: TrayMenuRow {
                                            required property var modelData

                                            width: entry.width
                                            indent: 14 * tray.scaleFactor
                                            entryData: modelData
                                            scaleFactor: tray.scaleFactor
                                            onActivated: {
                                                if (!modelData.hasChildren) {
                                                    modelData.triggered();
                                                    menu.open = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component ConnectivityPanel: Column {
        id: conn

        property real scaleFactor: 1
        property bool surfaceActive: visible
        property bool showHeader: true
        property int maxWifiRows: 5
        property int maxBtRows: 4
        property string wifiStatus: ""
        property string expandedSsid: ""
        property string wifiPassword: ""
        property string pendingWifiPassword: ""
        property var wifiRows: []

        readonly property var netDevices: (typeof Networking !== "undefined" && Networking && Networking.devices) ? Networking.devices.values : []
        readonly property var wifiDev: netDevices.find(function(d) { return d && d.type === DeviceType.Wifi }) || null
        readonly property string wifiIface: wifiDev ? (wifiDev.name || "") : ""
        readonly property bool wifiOn: (typeof Networking !== "undefined" && Networking) ? Networking.wifiEnabled : false
        readonly property var wifiActive: wifiRows.find(function(n) { return n && n.active }) || null

        readonly property var btAdapter: (typeof Bluetooth !== "undefined" && Bluetooth) ? Bluetooth.defaultAdapter : null
        readonly property var btDevices: (typeof Bluetooth !== "undefined" && Bluetooth && Bluetooth.devices) ? Bluetooth.devices.values : []
        readonly property var btDevicesSorted: btDevices.slice().sort(function(a, b) {
            function rank(d) {
                if (!d) return 4;
                if (d.connected) return 0;
                if (d.paired) return 1;
                if ((d.deviceName || d.name || "").length > 0) return 2;
                return 3;
            }
            var r = rank(a) - rank(b);
            if (r !== 0) return r;
            return String((a && (a.deviceName || a.name)) || "").localeCompare(String((b && (b.deviceName || b.name)) || ""));
        })
        readonly property int btConnectedCount: {
            var count = 0;
            for (var i = 0; i < btDevices.length; i++)
                if (btDevices[i] && btDevices[i].connected)
                    count++;
            return count;
        }

        spacing: 10 * scaleFactor

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

        function securityText(value) {
            if (!value || value === "--")
                return "open";
            return value;
        }

        function secured(row) {
            return row && row.security && row.security.length > 0 && row.security !== "--";
        }

        function parseWifi(text) {
            var map = {};
            var order = [];
            var lines = text.split("\n");
            for (var i = 0; i < lines.length; i++) {
                if (!lines[i].length)
                    continue;
                var parts = splitNm(lines[i]);
                if (parts.length < 4)
                    continue;
                var ssid = parts[1];
                if (!ssid || ssid.length === 0)
                    continue;
                var active = parts[0] === "*";
                var signal = Number(parts[3]);
                if (isNaN(signal))
                    signal = 0;
                var current = map[ssid];
                if (!current) {
                    order.push(ssid);
                    current = {
                        ssid: ssid,
                        active: active,
                        security: parts[2],
                        signal: signal
                    };
                    map[ssid] = current;
                } else if (active || signal > current.signal) {
                    current.active = active || current.active;
                    current.security = parts[2];
                    current.signal = signal;
                }
            }
            var rows = [];
            for (var j = 0; j < order.length; j++)
                rows.push(map[order[j]]);
            rows.sort(function(a, b) {
                if (a.active !== b.active)
                    return a.active ? -1 : 1;
                return b.signal - a.signal;
            });
            wifiRows = rows;
        }

        function refreshWifi() {
            if (!wifiListProc.running)
                wifiListProc.running = true;
        }

        function scanWifi() {
            if (!wifiScanProc.running) {
                wifiStatus = "Scanning";
                wifiScanProc.running = true;
            }
        }

        function toggleWifi() {
            if (wifiToggleProc.running)
                return;
            wifiToggleProc.command = ["nmcli", "radio", "wifi", wifiOn ? "off" : "on"];
            wifiStatus = wifiOn ? "Turning off" : "Turning on";
            wifiToggleProc.running = true;
        }

        function activateWifi(row) {
            if (!row || wifiConnectProc.running || wifiDisconnectProc.running)
                return;
            if (row.active) {
                if (wifiIface.length === 0) {
                    wifiStatus = "No Wi-Fi device";
                    wifiStatusClear.restart();
                    return;
                }
                wifiStatus = "Disconnecting";
                wifiDisconnectProc.command = ["nmcli", "device", "disconnect", wifiIface];
                wifiDisconnectProc.running = true;
                return;
            }
            if (secured(row)) {
                expandedSsid = expandedSsid === row.ssid ? "" : row.ssid;
                wifiPassword = "";
                wifiStatus = "";
                return;
            }
            connectWifi(row.ssid, "");
        }

        function connectWifi(ssid, password) {
            if (!ssid || wifiConnectProc.running)
                return;
            pendingWifiPassword = password || "";
            wifiStatus = "Connecting";
            wifiConnectProc.command = pendingWifiPassword.length > 0
                ? ["nmcli", "--ask", "dev", "wifi", "connect", ssid]
                : ["nmcli", "dev", "wifi", "connect", ssid];
            wifiConnectProc.running = true;
        }

        function btName(d) {
            return d ? (d.deviceName || d.name || d.address || "Unknown device") : "Unknown device";
        }

        function btMeta(d) {
            if (!d)
                return "";
            var parts = [];
            if (d.connected)
                parts.push("connected");
            else if (d.paired)
                parts.push("paired");
            else
                parts.push("new");
            if (d.state !== undefined && typeof BluetoothDeviceState !== "undefined") {
                var state = BluetoothDeviceState.toString(d.state);
                if (state && state.length > 0 && parts.indexOf(state.toLowerCase()) === -1)
                    parts.push(state.toLowerCase());
            }
            if (d.batteryAvailable) {
                var b = d.battery <= 1 ? d.battery * 100 : d.battery;
                if (b > 0)
                    parts.push(Math.round(b) + "%");
            }
            return parts.join(" · ");
        }

        function activateBt(d) {
            if (!d)
                return;
            if (d.connected) {
                d.disconnect();
            } else if (d.paired) {
                d.connect();
            } else {
                d.pair();
            }
        }

        onSurfaceActiveChanged: if (surfaceActive) refreshWifi()
        Component.onCompleted: refreshWifi()

        Binding {
            target: conn.wifiDev
            property: "scannerEnabled"
            value: conn.surfaceActive && conn.wifiOn
            when: conn.wifiDev !== null
        }

        Timer {
            interval: 7000
            running: conn.surfaceActive
            repeat: true
            triggeredOnStart: true
            onTriggered: conn.refreshWifi()
        }

        Timer {
            id: wifiStatusClear

            interval: 2200
            onTriggered: conn.wifiStatus = ""
        }

        Timer {
            id: btScanTimer

            interval: 25000
            repeat: false
            onTriggered: if (conn.btAdapter) conn.btAdapter.discovering = false
        }

        Process {
            id: wifiListProc

            command: ["nmcli", "-t", "-e", "yes", "-f", "IN-USE,SSID,SECURITY,SIGNAL", "dev", "wifi", "list", "--rescan", "no"]
            stdout: StdioCollector {
                onStreamFinished: conn.parseWifi(this.text)
            }
        }

        Process {
            id: wifiScanProc

            command: ["nmcli", "dev", "wifi", "rescan"]
            onExited: {
                conn.wifiStatus = "Scan complete";
                conn.refreshWifi();
                wifiStatusClear.restart();
            }
        }

        Process {
            id: wifiToggleProc

            onExited: function(exitCode) {
                conn.wifiStatus = exitCode === 0 ? "" : "Wi-Fi toggle failed";
                conn.refreshWifi();
                if (exitCode !== 0)
                    wifiStatusClear.restart();
            }
        }

        Process {
            id: wifiDisconnectProc

            onExited: function(exitCode) {
                conn.wifiStatus = exitCode === 0 ? "Disconnected" : "Disconnect failed";
                conn.refreshWifi();
                wifiStatusClear.restart();
            }
        }

        Process {
            id: wifiConnectProc

            stdinEnabled: true
            stdout: StdioCollector {}
            stderr: StdioCollector {}
            onStarted: {
                if (conn.pendingWifiPassword.length > 0) {
                    write(conn.pendingWifiPassword + "\n");
                    conn.pendingWifiPassword = "";
                }
            }
            onExited: function(exitCode) {
                conn.wifiStatus = exitCode === 0 ? "Connected" : "Connection failed";
                if (exitCode === 0) {
                    conn.expandedSsid = "";
                    conn.wifiPassword = "";
                }
                conn.refreshWifi();
                wifiStatusClear.restart();
            }
        }

        SectionTitle {
            visible: conn.showHeader
            width: parent.width
            overline: "Connectivity"
            heading: conn.wifiActive ? conn.wifiActive.ssid : (conn.btConnectedCount > 0 ? conn.btConnectedCount + " Bluetooth connected" : "Network and Bluetooth")
            scaleFactor: conn.scaleFactor
        }

        Rectangle {
            width: parent.width
            height: wifiSection.implicitHeight + 18 * conn.scaleFactor
            radius: 8 * conn.scaleFactor
            color: Qt.rgba(root.nord0.r, root.nord0.g, root.nord0.b, 0.50)
            border.width: 1
            border.color: root.nord3
            clip: true

            Column {
                id: wifiSection

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 9 * conn.scaleFactor
                spacing: 8 * conn.scaleFactor

                RowLayout {
                    width: parent.width
                    spacing: 8 * conn.scaleFactor

                    Text {
                        text: "󰖩"
                        color: conn.wifiOn ? root.nord8 : root.nord4
                        font.family: root.uiFont
                        font.pixelSize: 17 * conn.scaleFactor
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1 * conn.scaleFactor

                        Text {
                            Layout.fillWidth: true
                            text: "Wi-Fi"
                            color: root.nord6
                            elide: Text.ElideRight
                            font.family: root.uiFont
                            font.pixelSize: 13 * conn.scaleFactor
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: conn.wifiStatus.length > 0
                                ? conn.wifiStatus
                                : (conn.wifiActive ? conn.wifiActive.ssid : (conn.wifiOn ? "Not connected" : "Off"))
                            color: root.nord4
                            elide: Text.ElideRight
                            font.family: root.uiFont
                            font.pixelSize: 11 * conn.scaleFactor
                        }
                    }

                    ActionButton {
                        label: "Scan"
                        icon: "󰑓"
                        enabled: conn.wifiOn && !wifiScanProc.running
                        opacity: enabled ? 1 : 0.45
                        scaleFactor: conn.scaleFactor * 0.88
                        onActivated: conn.scanWifi()
                    }

                    ToggleSwitch {
                        checked: conn.wifiOn
                        scaleFactor: conn.scaleFactor
                        onToggled: conn.toggleWifi()
                    }
                }

                Column {
                    width: parent.width
                    spacing: 5 * conn.scaleFactor
                    visible: conn.wifiOn

                    Repeater {
                        model: conn.wifiRows.slice(0, conn.maxWifiRows)

                        delegate: Rectangle {
                            id: wifiRow

                            required property var modelData

                            readonly property bool expanded: conn.expandedSsid === modelData.ssid
                            readonly property bool active: modelData.active

                            width: parent.width
                            height: expanded ? 86 * conn.scaleFactor : 42 * conn.scaleFactor
                            radius: 7 * conn.scaleFactor
                            color: active ? Qt.rgba(root.nord10.r, root.nord10.g, root.nord10.b, 0.32)
                                : (wifiMouse.containsMouse ? root.nord2 : Qt.rgba(root.nord1.r, root.nord1.g, root.nord1.b, 0.45))
                            border.width: active || expanded ? 1 : 0
                            border.color: active || expanded ? root.nord8 : root.nord3
                            clip: true

                            Behavior on height {
                                NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
                            }

                            MouseArea {
                                id: wifiMouse

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: 42 * conn.scaleFactor
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: conn.activateWifi(wifiRow.modelData)
                            }

                            RowLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: 42 * conn.scaleFactor
                                anchors.leftMargin: 9 * conn.scaleFactor
                                anchors.rightMargin: 9 * conn.scaleFactor
                                spacing: 8 * conn.scaleFactor

                                Text {
                                    text: active ? "●" : (conn.secured(wifiRow.modelData) ? "" : "○")
                                    color: active ? root.nord8 : root.nord4
                                    font.family: root.uiFont
                                    font.pixelSize: 11 * conn.scaleFactor
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1 * conn.scaleFactor

                                    Text {
                                        Layout.fillWidth: true
                                        text: wifiRow.modelData.ssid
                                        color: active ? root.nord6 : root.nord5
                                        elide: Text.ElideRight
                                        font.family: root.uiFont
                                        font.pixelSize: 12 * conn.scaleFactor
                                        font.weight: active ? Font.DemiBold : Font.Normal
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: conn.securityText(wifiRow.modelData.security)
                                        color: root.nord4
                                        elide: Text.ElideRight
                                        font.family: root.uiFont
                                        font.pixelSize: 10 * conn.scaleFactor
                                    }
                                }

                                Text {
                                    text: Math.round(wifiRow.modelData.signal) + "%"
                                    color: root.nord4
                                    font.family: root.uiFont
                                    font.pixelSize: 11 * conn.scaleFactor
                                    font.weight: Font.DemiBold
                                }
                            }

                            RowLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.topMargin: 46 * conn.scaleFactor
                                anchors.leftMargin: 9 * conn.scaleFactor
                                anchors.rightMargin: 9 * conn.scaleFactor
                                height: 32 * conn.scaleFactor
                                spacing: 8 * conn.scaleFactor
                                visible: wifiRow.expanded

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 32 * conn.scaleFactor
                                    radius: 6 * conn.scaleFactor
                                    color: root.nord0
                                    border.width: 1
                                    border.color: root.nord3

                                    TextInput {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10 * conn.scaleFactor
                                        anchors.rightMargin: 10 * conn.scaleFactor
                                        verticalAlignment: TextInput.AlignVCenter
                                        text: conn.wifiPassword
                                        echoMode: TextInput.Password
                                        color: root.nord6
                                        selectionColor: root.nord10
                                        selectedTextColor: root.nord6
                                        font.family: root.uiFont
                                        font.pixelSize: 12 * conn.scaleFactor
                                        clip: true
                                        onTextEdited: conn.wifiPassword = text
                                        Keys.onReturnPressed: conn.connectWifi(wifiRow.modelData.ssid, conn.wifiPassword)
                                        Keys.onEnterPressed: conn.connectWifi(wifiRow.modelData.ssid, conn.wifiPassword)
                                    }
                                }

                                ActionButton {
                                    label: conn.wifiPassword.length > 0 ? "Join" : "Saved"
                                    icon: ""
                                    scaleFactor: conn.scaleFactor * 0.86
                                    onActivated: conn.connectWifi(wifiRow.modelData.ssid, conn.wifiPassword)
                                }
                            }
                        }
                    }

                    Text {
                        visible: conn.wifiRows.length === 0
                        width: parent.width
                        text: "No networks found"
                        color: root.nord4
                        font.family: root.uiFont
                        font.pixelSize: 12 * conn.scaleFactor
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: btSection.implicitHeight + 18 * conn.scaleFactor
            radius: 8 * conn.scaleFactor
            color: Qt.rgba(root.nord0.r, root.nord0.g, root.nord0.b, 0.50)
            border.width: 1
            border.color: root.nord3
            clip: true

            Column {
                id: btSection

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 9 * conn.scaleFactor
                spacing: 8 * conn.scaleFactor

                RowLayout {
                    width: parent.width
                    spacing: 8 * conn.scaleFactor

                    Text {
                        text: ""
                        color: conn.btAdapter && conn.btAdapter.enabled ? root.nord8 : root.nord4
                        font.family: root.uiFont
                        font.pixelSize: 17 * conn.scaleFactor
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1 * conn.scaleFactor

                        Text {
                            Layout.fillWidth: true
                            text: "Bluetooth"
                            color: root.nord6
                            elide: Text.ElideRight
                            font.family: root.uiFont
                            font.pixelSize: 13 * conn.scaleFactor
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: !conn.btAdapter ? "No adapter"
                                : (!conn.btAdapter.enabled ? "Off"
                                : (conn.btConnectedCount > 0 ? conn.btConnectedCount + " connected" : "No connected devices"))
                            color: root.nord4
                            elide: Text.ElideRight
                            font.family: root.uiFont
                            font.pixelSize: 11 * conn.scaleFactor
                        }
                    }

                    ActionButton {
                        label: conn.btAdapter && conn.btAdapter.discovering ? "Scanning" : "Scan"
                        icon: "󰑓"
                        enabled: conn.btAdapter && conn.btAdapter.enabled
                        opacity: enabled ? 1 : 0.45
                        active: conn.btAdapter && conn.btAdapter.discovering
                        scaleFactor: conn.scaleFactor * 0.88
                        onActivated: {
                            if (!conn.btAdapter)
                                return;
                            conn.btAdapter.discovering = !conn.btAdapter.discovering;
                            if (conn.btAdapter.discovering)
                                btScanTimer.restart();
                            else
                                btScanTimer.stop();
                        }
                    }

                    ToggleSwitch {
                        checked: conn.btAdapter ? conn.btAdapter.enabled : false
                        scaleFactor: conn.scaleFactor
                        onToggled: if (conn.btAdapter) conn.btAdapter.enabled = !conn.btAdapter.enabled
                    }
                }

                Column {
                    width: parent.width
                    spacing: 5 * conn.scaleFactor
                    visible: conn.btAdapter && conn.btAdapter.enabled

                    Repeater {
                        model: conn.btDevicesSorted.slice(0, conn.maxBtRows)

                        delegate: Rectangle {
                            id: btRow

                            required property var modelData

                            readonly property bool active: modelData && modelData.connected

                            width: parent.width
                            height: 42 * conn.scaleFactor
                            radius: 7 * conn.scaleFactor
                            color: active ? Qt.rgba(root.nord10.r, root.nord10.g, root.nord10.b, 0.32)
                                : (btMouse.containsMouse ? root.nord2 : Qt.rgba(root.nord1.r, root.nord1.g, root.nord1.b, 0.45))
                            border.width: active ? 1 : 0
                            border.color: active ? root.nord8 : root.nord3

                            MouseArea {
                                id: btMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: conn.activateBt(btRow.modelData)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 9 * conn.scaleFactor
                                anchors.rightMargin: 9 * conn.scaleFactor
                                spacing: 8 * conn.scaleFactor

                                Text {
                                    text: active ? "●" : "○"
                                    color: active ? root.nord8 : root.nord4
                                    font.family: root.uiFont
                                    font.pixelSize: 11 * conn.scaleFactor
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1 * conn.scaleFactor

                                    Text {
                                        Layout.fillWidth: true
                                        text: conn.btName(btRow.modelData)
                                        color: active ? root.nord6 : root.nord5
                                        elide: Text.ElideRight
                                        font.family: root.uiFont
                                        font.pixelSize: 12 * conn.scaleFactor
                                        font.weight: active ? Font.DemiBold : Font.Normal
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: conn.btMeta(btRow.modelData)
                                        color: root.nord4
                                        elide: Text.ElideRight
                                        font.family: root.uiFont
                                        font.pixelSize: 10 * conn.scaleFactor
                                    }
                                }

                                Text {
                                    text: btRow.active ? "Disconnect" : (btRow.modelData && btRow.modelData.paired ? "Connect" : "Pair")
                                    color: root.nord8
                                    font.family: root.uiFont
                                    font.pixelSize: 10 * conn.scaleFactor
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }

                    Text {
                        visible: conn.btDevicesSorted.length === 0
                        width: parent.width
                        text: conn.btAdapter && conn.btAdapter.discovering ? "Searching..." : "No Bluetooth devices"
                        color: root.nord4
                        font.family: root.uiFont
                        font.pixelSize: 12 * conn.scaleFactor
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overlay

            required property var modelData

            readonly property real s: modelData ? Math.max(0.78, Math.min(1.0, modelData.height / 1080)) : 1
            readonly property string mon: modelData ? modelData.name : ""
            readonly property bool surfaceOpen: root.openMon === mon && root.openSurface.length > 0
            readonly property bool forceOpen: root.peekMon === mon

            screen: modelData
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "nord-pill"
            WlrLayershell.keyboardFocus: surfaceOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            mask: surfaceOpen || forceOpen ? fullRegion : pillRegion

            Region {
                id: fullRegion
                width: overlay.width
                height: overlay.height
            }

            Region {
                id: pillRegion
                x: pill.x
                y: pill.y
                width: pill.width
                height: pill.height
            }

            MouseArea {
                anchors.fill: parent
                enabled: overlay.surfaceOpen || overlay.forceOpen
                acceptedButtons: Qt.AllButtons
                onPressed: {
                    root.peekMon = "";
                    root.close();
                }
            }

            FocusScope {
                anchors.fill: parent
                focus: overlay.surfaceOpen
                Keys.onEscapePressed: {
                    root.peekMon = "";
                    root.close();
                }

                Item {
                    id: pill

                    anchors.top: parent.top
                    anchors.topMargin: 36 * overlay.s
                    anchors.horizontalCenter: parent.horizontalCenter

                    property bool hovered: hover.hovered
                    readonly property bool expanded: hovered || overlay.forceOpen || overlay.surfaceOpen
                    readonly property string surface: overlay.surfaceOpen ? root.openSurface : ""
                    readonly property var player: {
                        var list = Mpris.players.values;
                        if (!list || list.length === 0) return null;
                        var fallback = null;
                        for (var i = 0; i < list.length; i++) {
                            var p = list[i];
                            if (!p) continue;
                            if (p.isPlaying) return p;
                            if (!fallback && p.canControl) fallback = p;
                        }
                        return fallback ? fallback : list[0];
                    }
                    readonly property bool hasPlayer: player !== null
                    readonly property string playerTitle: hasPlayer && player.trackTitle ? player.trackTitle : "No media"
                    readonly property string playerArtist: {
                        if (!hasPlayer) return "";
                        var artists = player.trackArtists;
                        if (artists && typeof artists.join === "function" && artists.length > 0)
                            return artists.join(", ");
                        if (artists && String(artists).length > 0)
                            return String(artists);
                        return player.trackArtist ? String(player.trackArtist) : "";
                    }
                    readonly property string activeWorkspace: {
                        var mons = Hyprland.monitors.values;
                        for (var i = 0; i < mons.length; i++) {
                            if (mons[i].name === overlay.mon)
                                return mons[i].activeWorkspace ? mons[i].activeWorkspace.name : "";
                        }
                        return "";
                    }

                    property bool dnd: false
                    property bool vpn: false

                    readonly property real maxW: Math.max(260 * overlay.s, overlay.width - 32 * overlay.s)
                    readonly property real frameRadius: pill.surface.length > 0 ? 10 * overlay.s : 8 * overlay.s
                    readonly property real compactLabelW: Math.min(126 * overlay.s, Math.max(48 * overlay.s, Math.min(root.activeWindowLabel.length, 16) * 8.5 * overlay.s))
                    readonly property real compactClockW: 86 * overlay.s
                    readonly property real restW: Math.min(maxW, Math.max(178 * overlay.s, compactLabelW + compactClockW + 40 * overlay.s))
                    readonly property real restH: 38 * overlay.s
                    readonly property real hoverW: Math.min(760 * overlay.s, maxW)
                    readonly property real hoverH: 52 * overlay.s
                    readonly property real calendarW: Math.min(390 * overlay.s, maxW)
                    readonly property real calendarH: 300 * overlay.s
                    readonly property real clipboardW: Math.min(520 * overlay.s, maxW)
                    readonly property real clipboardH: Math.min(430 * overlay.s, overlay.height - 120 * overlay.s)
                    readonly property real mediaW: Math.min(500 * overlay.s, maxW)
                    readonly property real mediaH: 260 * overlay.s
                    readonly property real linksW: Math.min(540 * overlay.s, maxW)
                    readonly property real linksH: Math.min(500 * overlay.s, overlay.height - 120 * overlay.s)
                    readonly property real powerW: Math.min(390 * overlay.s, maxW)
                    readonly property real powerH: 165 * overlay.s

                    width: surface === "calendar" ? calendarW
                        : surface === "clipboard" ? clipboardW
                        : surface === "mixer" || surface === "media" ? mediaW
                        : surface === "links" ? linksW
                        : surface === "power" ? powerW
                        : expanded ? hoverW
                        : restW
                    height: surface === "calendar" ? calendarH
                        : surface === "clipboard" ? clipboardH
                        : surface === "mixer" || surface === "media" ? mediaH
                        : surface === "links" ? linksH
                        : surface === "power" ? powerH
                        : expanded ? hoverH
                        : restH

                    Behavior on width {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }

                    Behavior on height {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }

                    function sh(command) {
                        Quickshell.execDetached(["sh", "-c", command]);
                    }

                    function closeAfter(command) {
                        sh(command);
                        root.peekMon = "";
                        root.close();
                    }

                    function toggleSurface(name) {
                        root.toggle(overlay.mon, name);
                    }

                    function refreshStatuses() {
                        if (!dndProc.running) dndProc.running = true;
                        if (!vpnProc.running) vpnProc.running = true;
                    }

                    Component.onCompleted: refreshStatuses()

                    Timer {
                        interval: 2500
                        running: true
                        repeat: true
                        onTriggered: pill.refreshStatuses()
                    }

                    Process {
                        id: dndProc
                        command: ["sh", "-c", "makoctl mode 2>/dev/null | grep -q dnd && printf dnd || printf default"]
                        stdout: StdioCollector {
                            onStreamFinished: pill.dnd = this.text.trim() === "dnd"
                        }
                    }

                    Process {
                        id: vpnProc
                        command: ["sh", "-c", "systemctl is-active wg-quick-wg0.service >/dev/null 2>&1 && printf on || printf off"]
                        stdout: StdioCollector {
                            onStreamFinished: pill.vpn = this.text.trim() === "on"
                        }
                    }

                    HoverHandler {
                        id: hover
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: pill.frameRadius
                        border.width: 1
                        border.color: pill.surface.length > 0 ? root.nord8 : root.nord10
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: root.nord1 }
                            GradientStop { position: 1.0; color: root.nord0 }
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 1
                            anchors.leftMargin: parent.radius * 0.65
                            anchors.rightMargin: parent.radius * 0.65
                            height: 1
                            color: Qt.rgba(root.nord6.r, root.nord6.g, root.nord6.b, 0.10)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: pill.surface.length === 0
                        acceptedButtons: Qt.LeftButton
                        onClicked: root.togglePeek(overlay.mon)
                    }

                    Item {
                        anchors.fill: parent
                        anchors.margins: 7 * overlay.s
                        visible: pill.surface.length === 0
                        opacity: pill.expanded ? 0 : 1

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8 * overlay.s

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: pill.compactLabelW
                                text: root.activeWindowLabel
                                color: root.nord8
                                elide: Text.ElideRight
                                font.family: root.uiFont
                                font.pixelSize: 14 * overlay.s
                                font.weight: Font.DemiBold
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 1
                                height: 18 * overlay.s
                                color: root.nord3
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: pill.compactClockW
                                horizontalAlignment: Text.AlignRight
                                text: Qt.formatTime(clock.date, "HH:mm:ss")
                                color: root.nord6
                                font.family: root.uiFont
                                font.pixelSize: 16 * overlay.s
                                font.weight: Font.Bold
                                font.features: { "tnum": 1 }
                            }
                        }
                    }

                    Item {
                        anchors.fill: parent
                        anchors.margins: 8 * overlay.s
                        visible: pill.surface.length === 0
                        opacity: pill.expanded ? 1 : 0
                        clip: true

                        Behavior on opacity {
                            NumberAnimation { duration: 120 }
                        }

                        Row {
                            id: hoverRow
                            anchors.centerIn: parent
                            spacing: 8 * overlay.s

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: pill.width >= 620 * overlay.s
                                spacing: 4 * overlay.s

                                Repeater {
                                    model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

                                    Rectangle {
                                        required property int modelData

                                        readonly property bool active: pill.activeWorkspace === String(modelData)

                                        width: active ? 20 * overlay.s : 10 * overlay.s
                                        height: 18 * overlay.s
                                        radius: 5 * overlay.s
                                        color: wsArea.containsMouse ? root.nord2 : "transparent"

                                        Behavior on width {
                                            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                                        }

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: parent.active ? 15 * overlay.s : 5 * overlay.s
                                            height: 5 * overlay.s
                                            radius: 2 * overlay.s
                                            color: parent.active ? root.nord8 : root.nord4
                                            opacity: parent.active ? 1 : (wsArea.containsMouse ? 0.75 : 0.35)
                                        }

                                        MouseArea {
                                            id: wsArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Hyprland.dispatch("workspace " + modelData)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: pill.width >= 620 * overlay.s
                                width: 1
                                height: 22 * overlay.s
                                color: root.nord3
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 80 * overlay.s
                                spacing: 1 * overlay.s

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Qt.formatTime(clock.date, "HH:mm:ss")
                                    color: root.nord6
                                    font.family: root.uiFont
                                    font.pixelSize: 16 * overlay.s
                                    font.weight: Font.Bold
                                    font.features: { "tnum": 1 }
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Qt.formatDate(clock.date, "ddd d MMM")
                                    color: root.nord4
                                    font.family: root.uiFont
                                    font.pixelSize: 10 * overlay.s
                                }
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 1
                                height: 22 * overlay.s
                                color: root.nord3
                            }

                            TrayStrip {
                                scaleFactor: overlay.s
                                hostWindow: overlay
                                menuTop: pill.y + pill.height + 6 * overlay.s
                                maxStripWidth: 110 * overlay.s
                                visible: itemCount > 0 && pill.width >= 680 * overlay.s
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: SystemTray.items.values.length > 0 && pill.width >= 680 * overlay.s
                                width: 1
                                height: 22 * overlay.s
                                color: root.nord3
                            }

                            IconButton {
                                icon: ""
                                label: "Apps"
                                scaleFactor: overlay.s
                                onActivated: pill.closeAfter("fuzzel")
                            }

                            IconButton {
                                icon: "󰝚"
                                label: "Media and audio"
                                active: pill.hasPlayer && pill.player.isPlaying
                                scaleFactor: overlay.s
                                onActivated: pill.toggleSurface("media")
                            }

                            IconButton {
                                icon: ""
                                label: "Calendar"
                                scaleFactor: overlay.s
                                onActivated: pill.toggleSurface("calendar")
                            }

                            IconButton {
                                icon: "󰖩"
                                label: "Connectivity"
                                active: pill.vpn || pill.dnd
                                scaleFactor: overlay.s
                                onActivated: pill.toggleSurface("links")
                            }

                            IconButton {
                                icon: "󰕮"
                                label: "Sidebar"
                                active: root.sidebarShown && root.sidebarMon === overlay.mon
                                scaleFactor: overlay.s
                                onActivated: root.toggleSidebar(overlay.mon)
                            }

                            IconButton {
                                icon: "⏻"
                                label: "Power"
                                scaleFactor: overlay.s
                                onActivated: pill.toggleSurface("power")
                            }
                        }
                    }

                    Loader {
                        anchors.fill: parent
                        anchors.margins: 14 * overlay.s
                        active: pill.surface.length > 0
                        sourceComponent: pill.surface === "calendar" ? calendarSurface
                            : pill.surface === "clipboard" ? clipboardSurface
                            : pill.surface === "mixer" || pill.surface === "media" ? mediaSurface
                            : pill.surface === "links" ? linksSurface
                            : pill.surface === "power" ? powerSurface
                            : null
                    }

                    SystemClock {
                        id: clock
                        precision: SystemClock.Seconds
                    }

                    Component {
                        id: clipboardSurface

                        FocusScope {
                            id: clip

                            property string query: ""
                            property string copyStatus: ""
	                            property int selectedIndex: 0
	                            property var entries: []
	                            readonly property var results: {
	                                var source = entries || [];
	                                var q = query.trim().toLowerCase();
	                                if (q.length === 0)
	                                    return source;
	                                var out = [];
	                                for (var i = 0; i < source.length; i++) {
	                                    var e = source[i];
	                                    var hay = ((e.preview || "") + " " + (e.meta || "")).toLowerCase();
	                                    if (hay.indexOf(q) !== -1)
	                                        out.push(e);
	                                }
                                return out;
	                            }

	                            function clampSelection() {
	                                var current = results || [];
	                                if (current.length === 0) {
	                                    selectedIndex = 0;
	                                } else if (selectedIndex >= current.length) {
	                                    selectedIndex = current.length - 1;
	                                } else if (selectedIndex < 0) {
	                                    selectedIndex = 0;
	                                }
	                            }

	                            function move(delta) {
	                                var current = results || [];
	                                if (current.length === 0)
	                                    return;
	                                selectedIndex = Math.max(0, Math.min(current.length - 1, selectedIndex + delta));
                                list.positionViewAtIndex(selectedIndex, ListView.Contain);
                            }

                            function parse(text) {
                                var rows = [];
                                var lines = text.split("\n");
                                for (var i = 0; i < lines.length; i++) {
                                    var line = lines[i];
                                    if (!line.length)
                                        continue;
                                    var tab = line.indexOf("\t");
                                    if (tab <= 0)
                                        continue;
                                    var id = line.slice(0, tab);
                                    var rawPreview = line.slice(tab + 1);
                                    var preview = rawPreview
                                        .replace(/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/g, "")
                                        .replace(/\s+/g, " ")
                                        .trim();
                                    var binary = preview.indexOf("[[ binary data") === 0;
                                    var meta = binary ? preview.replace(/^\[\[ binary data /, "").replace(/ \]\]$/, "") : "";
                                    if (!binary && preview.length === 0)
                                        preview = "Clipboard entry";
                                    rows.push({
                                        id: id,
                                        key: line,
                                        preview: binary ? "Image" : preview,
                                        meta: meta,
                                        binary: binary
                                    });
                                }
                                entries = rows;
                                clampSelection();
                            }

                            function refresh() {
                                if (!thumbProc.running)
                                    thumbProc.running = true;
                                if (!listProc.running)
                                    listProc.running = true;
                            }

                            function activate(entry) {
                                if (!entry)
                                    return;
                                if (copyProc.running)
                                    return;
                                copyStatus = "Copying";
                                copyProc.run(entry.key || entry.id, entry.binary);
                            }

                            function remove(entry) {
                                if (!entry)
                                    return;
                                Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "_", String(entry.id)]);
                                refreshLater.restart();
                            }

                            function wipe() {
                                Quickshell.execDetached(["cliphist", "wipe"]);
                                entries = [];
                                selectedIndex = 0;
                            }

                            focus: true
                            Keys.onEscapePressed: root.hideAll()
                            Keys.onReturnPressed: clip.activate(clip.results[clip.selectedIndex])
                            Keys.onEnterPressed: clip.activate(clip.results[clip.selectedIndex])

                            Component.onCompleted: {
                                refresh();
                                Qt.callLater(search.forceActiveFocus);
                            }

                            onQueryChanged: {
                                selectedIndex = 0;
                                clampSelection();
                            }
                            onEntriesChanged: clampSelection()

                            Process {
                                id: thumbProc
                                command: ["nord-cliphist-thumbs"]
                            }

                            Process {
                                id: listProc
                                command: ["cliphist", "list"]
                                stdout: StdioCollector {
                                    onStreamFinished: clip.parse(this.text)
                                }
                            }

                            Process {
                                id: copyProc

                                function run(key, binary) {
                                    command = binary
                                        ? ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", String(key)]
                                        : ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy --type 'text/plain;charset=utf-8'", "sh", String(key)];
                                    running = true;
                                }

                                onExited: function(exitCode) {
                                    if (exitCode === 0) {
                                        clip.copyStatus = "Copied";
                                        root.hideAll();
                                    } else {
                                        clip.copyStatus = "Copy failed";
                                        statusClear.restart();
                                    }
                                }
                            }

                            Timer {
                                id: refreshLater
                                interval: 250
                                onTriggered: clip.refresh()
                            }

                            Timer {
                                id: statusClear
                                interval: 1400
                                onTriggered: clip.copyStatus = ""
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 10 * overlay.s

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10 * overlay.s

	                                    Rectangle {
	                                        Layout.fillWidth: true
	                                        height: 38 * overlay.s
	                                        radius: 7 * overlay.s
                                        color: root.nord0
                                        border.width: 1
                                        border.color: root.nord3

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12 * overlay.s
                                            anchors.rightMargin: 12 * overlay.s
                                            spacing: 9 * overlay.s

                                            Text {
                                                text: ""
                                                color: root.nord8
                                                font.family: root.uiFont
	                                                font.pixelSize: 14 * overlay.s
                                            }

                                            TextInput {
                                                id: search
                                                Layout.fillWidth: true
                                                color: root.nord6
                                                selectionColor: root.nord10
                                                selectedTextColor: root.nord6
                                                clip: true
                                                font.family: root.uiFont
	                                                font.pixelSize: 14 * overlay.s
                                                text: clip.query
                                                onTextEdited: clip.query = text
                                                Keys.onPressed: function(event) {
                                                    if (event.key === Qt.Key_Down) {
                                                        clip.move(1);
                                                        event.accepted = true;
                                                    } else if (event.key === Qt.Key_Up) {
                                                        clip.move(-1);
                                                        event.accepted = true;
                                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                                        clip.activate(clip.results[clip.selectedIndex]);
                                                        event.accepted = true;
                                                    } else if (event.key === Qt.Key_Delete && clip.results.length > 0) {
                                                        clip.remove(clip.results[clip.selectedIndex]);
                                                        event.accepted = true;
                                                    }
                                                }
                                            }

                                            Text {
                                                text: clip.copyStatus.length > 0 ? clip.copyStatus : clip.results.length + "/" + clip.entries.length
                                                color: clip.copyStatus === "Copy failed" ? root.nord11 : root.nord4
                                                font.family: root.uiFont
	                                                font.pixelSize: 11 * overlay.s
                                            }
                                        }
                                    }

                                    IconButton {
                                        icon: "󰑓"
                                        label: "Refresh"
                                        scaleFactor: overlay.s
                                        onActivated: clip.refresh()
                                    }

                                    IconButton {
                                        icon: "󰆴"
                                        label: "Wipe"
                                        scaleFactor: overlay.s
                                        onActivated: clip.wipe()
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: root.nord3
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Text {
                                        anchors.centerIn: parent
                                        visible: clip.results.length === 0
                                        text: clip.query.length > 0 ? "No matches" : "Clipboard history is empty"
                                        color: root.nord4
                                        font.family: root.uiFont
                                        font.pixelSize: 12 * overlay.s
                                    }

                                    ListView {
                                        id: list
                                        anchors.fill: parent
                                        clip: true
                                        spacing: 4 * overlay.s
                                        boundsBehavior: Flickable.StopAtBounds
                                        model: clip.results

                                        delegate: Rectangle {
                                            id: row

                                            required property var modelData
                                            required property int index

                                            readonly property bool selected: index === clip.selectedIndex

                                            width: list.width
                                            height: modelData.binary ? 58 * overlay.s : 38 * overlay.s
	                                            radius: 7 * overlay.s
                                            color: selected ? root.nord2 : (rowArea.containsMouse ? Qt.rgba(root.nord2.r, root.nord2.g, root.nord2.b, 0.55) : "transparent")
                                            border.width: selected ? 1 : 0
                                            border.color: root.nord8

                                            MouseArea {
                                                id: rowArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                onEntered: clip.selectedIndex = row.index
                                                onClicked: function(mouse) {
                                                    if (mouse.button === Qt.RightButton)
                                                        clip.remove(row.modelData);
                                                    else
                                                        clip.activate(row.modelData);
                                                }
                                            }

                                            Rectangle {
                                                id: thumb
                                                visible: row.modelData.binary
                                                anchors.left: parent.left
                                                anchors.leftMargin: 9 * overlay.s
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: visible ? 62 * overlay.s : 0
                                                height: 42 * overlay.s
	                                                radius: 5 * overlay.s
                                                color: root.nord0
                                                border.width: 1
                                                border.color: root.nord3
                                                clip: true

                                                Image {
	                                                    id: thumbImage
	                                                    anchors.fill: parent
	                                                    anchors.margins: 2 * overlay.s
	                                                    source: row.modelData.binary ? "file://" + root.thumbPath(row.modelData.id) : ""
	                                                    fillMode: Image.PreserveAspectCrop
	                                                    asynchronous: true
	                                                    smooth: true
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    visible: parent.visible && thumbImage.status !== Image.Ready
                                                    text: "IMG"
                                                    color: root.nord4
                                                    opacity: 0.4
                                                    font.family: root.uiFont
	                                                    font.pixelSize: 10 * overlay.s
                                                    font.weight: Font.Bold
                                                }
                                            }

                                            Column {
                                                anchors.left: row.modelData.binary ? thumb.right : parent.left
                                                anchors.leftMargin: row.modelData.binary ? 10 * overlay.s : 12 * overlay.s
                                                anchors.right: deleteGlyph.left
                                                anchors.rightMargin: 10 * overlay.s
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 3 * overlay.s

                                                Text {
                                                    width: parent.width
                                                    text: row.modelData.preview
                                                    color: root.nord6
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 1
                                                    font.family: root.uiFont
	                                                    font.pixelSize: 13 * overlay.s
                                                    font.weight: Font.DemiBold
                                                }

                                                Text {
                                                    width: parent.width
                                                    visible: row.modelData.meta.length > 0
                                                    text: row.modelData.meta
                                                    color: root.nord4
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 1
                                                    font.family: root.uiFont
	                                                    font.pixelSize: 11 * overlay.s
                                                }
                                            }

                                            Text {
                                                id: deleteGlyph
                                                anchors.right: parent.right
                                                anchors.rightMargin: 11 * overlay.s
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "󰆴"
                                                color: rowArea.containsMouse ? root.nord11 : root.nord4
                                                opacity: rowArea.containsMouse ? 1 : 0.35
                                                font.family: root.uiFont
	                                                font.pixelSize: 14 * overlay.s

                                                MouseArea {
                                                    anchors.fill: parent
                                                    anchors.margins: -8 * overlay.s
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: clip.remove(row.modelData)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Component {
                        id: calendarSurface

                        Item {
                            property date today: clock.date
                            property int viewYear: today.getFullYear()
                            property int viewMonth: today.getMonth()
	                            readonly property var loc: Qt.locale("en_US")
	                            readonly property int offset: firstWeekdayOffset(viewYear, viewMonth)
	                            readonly property int days: daysInMonth(viewYear, viewMonth)

	                            function firstWeekdayOffset(year, month) {
	                                var d = new Date(year, month, 1).getDay();
	                                return (d + 6) % 7;
                            }

                            function daysInMonth(year, month) {
                                return new Date(year, month + 1, 0).getDate();
                            }

                            function shiftMonth(delta) {
                                var m = viewMonth + delta;
                                var y = viewYear;
                                while (m < 0) {
                                    m += 12;
                                    y -= 1;
                                }
                                while (m > 11) {
                                    m -= 12;
                                    y += 1;
                                }
	                                viewMonth = m;
	                                viewYear = y;
	                            }

	                            function dateForCell(index) {
	                                return new Date(viewYear, viewMonth, index - offset + 1);
	                            }

	                            ColumnLayout {
	                                anchors.fill: parent
	                                spacing: 12 * overlay.s

                                RowLayout {
                                    Layout.fillWidth: true

                                    SectionTitle {
                                        overline: "Calendar"
                                        heading: loc.standaloneMonthName(viewMonth, Locale.LongFormat) + " " + viewYear
                                        scaleFactor: overlay.s
                                        Layout.fillWidth: true
                                    }

                                    ActionButton {
                                        label: "Prev"
                                        icon: ""
                                        scaleFactor: overlay.s
                                        onActivated: shiftMonth(-1)
                                    }

                                    ActionButton {
                                        label: "Next"
                                        icon: ""
                                        scaleFactor: overlay.s
                                        onActivated: shiftMonth(1)
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: root.nord3
                                }

	                                Column {
	                                    Layout.fillWidth: true
	                                    Layout.fillHeight: true
	                                    spacing: 6 * overlay.s

	                                    Row {
	                                        id: weekdayRow

	                                        width: parent.width
	                                        height: 18 * overlay.s

	                                        Repeater {
	                                            model: ["M", "T", "W", "T", "F", "S", "S"]

	                                            Text {
	                                                required property string modelData

	                                                width: weekdayRow.width / 7
	                                                height: weekdayRow.height
	                                                horizontalAlignment: Text.AlignHCenter
	                                                verticalAlignment: Text.AlignVCenter
	                                                text: modelData
	                                                color: root.nord8
	                                                font.family: root.uiFont
	                                                font.pixelSize: 11 * overlay.s
	                                                font.weight: Font.DemiBold
	                                            }
	                                        }
	                                    }

	                                    Grid {
	                                        id: dayGrid

	                                        width: parent.width
	                                        height: parent.height - weekdayRow.height - parent.spacing
	                                        columns: 7
	                                        rows: 6
	                                        rowSpacing: 4 * overlay.s
	                                        columnSpacing: 4 * overlay.s

	                                        Repeater {
	                                            model: 42

	                                            Rectangle {
	                                                required property int index

	                                                readonly property date cellDate: dateForCell(index)
	                                                readonly property bool inMonth: cellDate.getMonth() === viewMonth
	                                                    && cellDate.getFullYear() === viewYear
	                                                readonly property bool current: cellDate.getDate() === today.getDate()
	                                                    && cellDate.getMonth() === today.getMonth()
	                                                    && cellDate.getFullYear() === today.getFullYear()

	                                                width: (dayGrid.width - dayGrid.columnSpacing * 6) / 7
	                                                height: (dayGrid.height - dayGrid.rowSpacing * 5) / 6
	                                                radius: 5 * overlay.s
	                                                color: current ? root.nord10
	                                                    : inMonth && dayArea.containsMouse ? Qt.rgba(root.nord2.r, root.nord2.g, root.nord2.b, 0.55)
	                                                    : "transparent"
	                                                border.width: current ? 1 : 0
	                                                border.color: root.nord8

	                                                Text {
	                                                    anchors.centerIn: parent
	                                                    text: parent.cellDate.getDate()
	                                                    color: parent.current ? root.nord6 : (parent.inMonth ? root.nord4 : root.nord3)
	                                                    opacity: parent.inMonth ? 1 : 0.45
	                                                    font.family: root.uiFont
	                                                    font.pixelSize: 13 * overlay.s
	                                                    font.weight: parent.current ? Font.Bold : Font.Normal
	                                                }

	                                                MouseArea {
	                                                    id: dayArea
	                                                    anchors.fill: parent
	                                                    hoverEnabled: parent.inMonth
	                                                    acceptedButtons: Qt.NoButton
	                                                }
	                                            }
	                                        }
	                                    }
	                                }
	                            }
	                        }
	                    }

                    Component {
                        id: mediaSurface

                        ColumnLayout {
                            spacing: 10 * overlay.s

                            RowLayout {
                                Layout.fillWidth: true

                                SectionTitle {
                                    overline: "Media + audio"
                                    heading: pill.playerTitle
                                    scaleFactor: overlay.s
                                    Layout.fillWidth: true
                                }

                                ActionButton {
                                    label: "Spotify"
                                    icon: ""
                                    scaleFactor: overlay.s
                                    onActivated: pill.closeAfter("spotify")
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: pill.playerArtist.length > 0 ? pill.playerArtist : "No active MPRIS player"
                                color: root.nord4
                                elide: Text.ElideRight
                                font.family: root.uiFont
	                                font.pixelSize: 13 * overlay.s
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: root.nord3
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10 * overlay.s

                                ActionButton {
                                    label: "Prev"
                                    icon: ""
                                    enabled: pill.hasPlayer && pill.player.canGoPrevious
                                    opacity: enabled ? 1 : 0.45
                                    scaleFactor: overlay.s
                                    onActivated: if (pill.player) pill.player.previous()
                                }

                                ActionButton {
                                    label: pill.hasPlayer && pill.player.isPlaying ? "Pause" : "Play"
                                    icon: pill.hasPlayer && pill.player.isPlaying ? "" : ""
                                    enabled: pill.hasPlayer && pill.player.canTogglePlaying
                                    opacity: enabled ? 1 : 0.45
                                    active: pill.hasPlayer && pill.player.isPlaying
                                    scaleFactor: overlay.s
                                    onActivated: if (pill.player) pill.player.togglePlaying()
                                }

                                ActionButton {
                                    label: "Next"
                                    icon: ""
                                    enabled: pill.hasPlayer && pill.player.canGoNext
                                    opacity: enabled ? 1 : 0.45
                                    scaleFactor: overlay.s
                                    onActivated: if (pill.player) pill.player.next()
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: root.nord3
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 3
                                rowSpacing: 9 * overlay.s
                                columnSpacing: 9 * overlay.s

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Vol -"
                                    icon: ""
                                    scaleFactor: overlay.s
                                    onActivated: pill.sh("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Mute"
                                    icon: "󰖁"
                                    scaleFactor: overlay.s
                                    onActivated: pill.sh("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Vol +"
                                    icon: ""
                                    scaleFactor: overlay.s
                                    onActivated: pill.sh("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Mic"
                                    icon: ""
                                    scaleFactor: overlay.s
                                    onActivated: pill.sh("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Pavu"
                                    icon: "󰕾"
                                    scaleFactor: overlay.s
                                    onActivated: pill.closeAfter("pavucontrol")
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Wiremix"
                                    icon: ""
                                    scaleFactor: overlay.s
                                    onActivated: pill.closeAfter("kitty wiremix")
                                }
                            }
                        }
                    }

                    Component {
                        id: linksSurface

                        Flickable {
                            contentHeight: linksContent.implicitHeight
                            boundsBehavior: Flickable.StopAtBounds
                            clip: true

                            Column {
                                id: linksContent

                                width: parent.width
                                spacing: 10 * overlay.s

                                ConnectivityPanel {
                                    width: parent.width
                                    scaleFactor: overlay.s
                                    surfaceActive: pill.surface === "links"
                                    showHeader: true
                                    maxWifiRows: 4
                                    maxBtRows: 3
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: root.nord3
                                }

                                GridLayout {
                                    width: parent.width
                                    columns: 2
                                    rowSpacing: 9 * overlay.s
                                    columnSpacing: 9 * overlay.s

                                    ActionButton {
                                        Layout.fillWidth: true
                                        label: pill.vpn ? "VPN on" : "VPN off"
                                        icon: ""
                                        active: pill.vpn
                                        scaleFactor: overlay.s
                                        onActivated: {
                                            pill.sh("if systemctl is-active --quiet wg-quick-wg0.service; then pkexec systemctl stop wg-quick-wg0.service; else pkexec systemctl start wg-quick-wg0.service; fi");
                                            linksRefresh.restart();
                                        }
                                    }

                                    ActionButton {
                                        Layout.fillWidth: true
                                        label: pill.dnd ? "DND on" : "DND off"
                                        icon: "󰍡"
                                        active: pill.dnd
                                        scaleFactor: overlay.s
                                        onActivated: {
                                            pill.sh("makoctl mode | grep -q dnd && makoctl mode -r dnd || makoctl mode -a dnd");
                                            linksRefresh.restart();
                                        }
                                    }
                                }

                                Timer {
                                    id: linksRefresh
                                    interval: 700
                                    onTriggered: pill.refreshStatuses()
                                }
                            }
                        }
                    }

                    Component {
                        id: powerSurface

                        ColumnLayout {
                            spacing: 12 * overlay.s

                            SectionTitle {
                                overline: "Power"
                                heading: "Session controls"
                                scaleFactor: overlay.s
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: root.nord3
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                rowSpacing: 10 * overlay.s
                                columnSpacing: 10 * overlay.s

                                ActionButton {
                                    label: "Lock"
                                    icon: ""
                                    scaleFactor: overlay.s
                                    onActivated: pill.closeAfter("hyprlock")
                                }

                                ActionButton {
                                    label: "Logout"
                                    icon: "󰗽"
                                    scaleFactor: overlay.s
                                    onActivated: pill.closeAfter("hyprctl dispatch exit")
                                }

                                ActionButton {
                                    label: "Sleep"
                                    icon: "󰒲"
                                    scaleFactor: overlay.s
                                    onActivated: pill.closeAfter("systemctl suspend")
                                }

                                ActionButton {
                                    label: "Wlogout"
                                    icon: "⏻"
                                    scaleFactor: overlay.s
                                    onActivated: pill.closeAfter("wlogout -b 5 -c 0 -r 0 -m 0 -C /home/berkerz/dotfiles/modules/wlogout/style2.css --protocol layer-shell")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PanelWindow {
        id: inhibitWin

        visible: root.keepAwake
        implicitWidth: 1
        implicitHeight: 1
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "nord-pill-inhibit"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            left: true
        }

        IdleInhibitor {
            window: inhibitWin
            enabled: root.keepAwake
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: sidebarWin

            required property var modelData

            readonly property real s: modelData ? Math.max(0.9, Math.min(1.05, modelData.height / 1080)) : 1
            readonly property string mon: modelData ? modelData.name : ""
            readonly property bool active: root.sidebarShown && (root.sidebarMon === "" || root.sidebarMon === mon)
            readonly property real panelWidth: Math.min(390 * s, width - 24 * s)
            readonly property var player: {
                var list = Mpris.players.values;
                if (!list || list.length === 0) return null;
                var fallback = null;
                for (var i = 0; i < list.length; i++) {
                    var p = list[i];
                    if (!p) continue;
                    if (p.isPlaying) return p;
                    if (!fallback && p.canControl) fallback = p;
                }
                return fallback ? fallback : list[0];
            }
            readonly property bool hasPlayer: player !== null
            readonly property string playerTitle: hasPlayer && player.trackTitle ? player.trackTitle : "No active media"
            readonly property string playerArtist: {
                if (!hasPlayer) return "";
                var artists = player.trackArtists;
                if (artists && typeof artists.join === "function" && artists.length > 0)
                    return artists.join(", ");
                if (artists && String(artists).length > 0)
                    return String(artists);
                return player.trackArtist ? String(player.trackArtist) : "";
            }

            property bool dnd: false
            property bool vpn: false
            property string volumeText: ""
            property string micText: ""
            property var notifications: []
            property var hiddenHistoryIds: ({})

            readonly property var notificationGroups: {
                var map = {};
                var order = [];
                for (var i = 0; i < notifications.length; i++) {
                    var n = notifications[i];
                    if (map[n.app] === undefined) {
                        map[n.app] = [];
                        order.push(n.app);
                    }
                    map[n.app].push(n);
                }
                var groups = [];
                for (var j = 0; j < order.length; j++) {
                    var app = order[j];
                    var items = map[app];
                    items.sort(function(a, b) { return b.id - a.id; });
                    groups.push({
                        app: app,
                        items: items,
                        count: items.length,
                        newestId: items.length > 0 ? items[0].id : 0
                    });
                }
                groups.sort(function(a, b) { return b.newestId - a.newestId; });
                return groups;
            }

            function refreshStatuses() {
                if (!sideDndProc.running) sideDndProc.running = true;
                if (!sideVpnProc.running) sideVpnProc.running = true;
                if (!volumeProc.running) volumeProc.running = true;
                if (!micProc.running) micProc.running = true;
                if (!notificationProc.running) notificationProc.running = true;
            }

            function parseNotifications(text) {
                var parsed = {};
                try {
                    parsed = JSON.parse(text && text.length > 0 ? text : "{\"active\":[],\"history\":[]}");
                } catch (e) {
                    notifications = [];
                    return;
                }

                var out = [];
                var seen = {};

                function addItems(items, live) {
                    if (!items)
                        return;
                    for (var i = 0; i < items.length; i++) {
                        var item = items[i];
                        var id = Number(item.id);
                        if (isNaN(id) || seen[id])
                            continue;
                        if (!live && hiddenHistoryIds[id])
                            continue;
                        seen[id] = true;
                        var app = item.app_name || item.desktop_entry || "System";
                        out.push({
                            id: id,
                            live: live,
                            app: String(app),
                            summary: item.summary ? String(item.summary) : "Notification",
                            body: item.body ? String(item.body) : "",
                            urgency: item.urgency ? String(item.urgency) : "normal",
                            appIcon: item.app_icon ? String(item.app_icon) : "",
                            desktopEntry: item.desktop_entry ? String(item.desktop_entry) : ""
                        });
                    }
                }

                addItems(parsed.active, true);
                addItems(parsed.history, false);
                out.sort(function(a, b) { return b.id - a.id; });
                notifications = out;
            }

            function hideHistoryIds(items) {
                var hidden = Object.assign({}, hiddenHistoryIds);
                for (var i = 0; i < items.length; i++) {
                    var item = items[i];
                    var id = Number(item.id || item);
                    if (isNaN(id))
                        continue;
                    hidden[id] = true;
                }
                hiddenHistoryIds = hidden;
            }

            function clearNotification(item) {
                if (!item)
                    return;
                var n = Number(item.id);
                if (isNaN(n))
                    return;
                if (item.live) {
                    Quickshell.execDetached(["makoctl", "dismiss", "-n", String(n), "--no-history"]);
                } else {
                    hideHistoryIds([item]);
                    notifications = notifications.filter(function(existing) { return existing.id !== n; });
                }
                notificationRefresh.restart();
            }

            function clearNotificationGroup(group) {
                if (!group || !group.items || group.items.length === 0)
                    return;
                var args = ["sh", "-c", "for id in \"$@\"; do makoctl dismiss -n \"$id\" --no-history; done", "sh"];
                var history = [];
                for (var i = 0; i < group.items.length; i++) {
                    if (group.items[i].live)
                        args.push(String(group.items[i].id));
                    else
                        history.push(group.items[i]);
                }
                if (history.length > 0)
                    hideHistoryIds(history);
                if (args.length > 4)
                    Quickshell.execDetached(args);
                notifications = notifications.filter(function(existing) { return existing.app !== group.app; });
                notificationRefresh.restart();
            }

            function clearAllNotifications() {
                Quickshell.execDetached(["makoctl", "dismiss", "--all", "--no-history"]);
                hideHistoryIds(notifications.filter(function(item) { return !item.live; }));
                notifications = [];
                notificationRefresh.restart();
            }

            screen: modelData
            visible: active
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "nord-sidebar"
            WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }

            onVisibleChanged: if (visible) refreshStatuses()

            MouseArea {
                anchors.fill: parent
                enabled: sidebarWin.active
                onClicked: root.sidebarShown = false
            }

            Process {
                id: sideDndProc
                command: ["sh", "-c", "makoctl mode 2>/dev/null | grep -q dnd && printf dnd || printf default"]
                stdout: StdioCollector {
                    onStreamFinished: sidebarWin.dnd = this.text.trim() === "dnd"
                }
            }

            Process {
                id: sideVpnProc
                command: ["sh", "-c", "systemctl is-active wg-quick-wg0.service >/dev/null 2>&1 && printf on || printf off"]
                stdout: StdioCollector {
                    onStreamFinished: sidebarWin.vpn = this.text.trim() === "on"
                }
            }

            Process {
                id: volumeProc
                command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{v=int($2*100+0.5); if ($0 ~ /MUTED/) printf v \"% muted\"; else printf v \"%\"}'"]
                stdout: StdioCollector {
                    onStreamFinished: sidebarWin.volumeText = this.text.trim()
                }
            }

            Process {
                id: micProc
                command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | awk '{v=int($2*100+0.5); if ($0 ~ /MUTED/) printf v \"% muted\"; else printf v \"%\"}'"]
                stdout: StdioCollector {
                    onStreamFinished: sidebarWin.micText = this.text.trim()
                }
            }

            Process {
                id: notificationProc
                command: ["sh", "-c", "printf '{\"active\":'; makoctl list -j 2>/dev/null || printf '[]'; printf ',\"history\":'; makoctl history -j 2>/dev/null || printf '[]'; printf '}'"]
                stdout: StdioCollector {
                    onStreamFinished: sidebarWin.parseNotifications(this.text.trim())
                }
            }

            Timer {
                interval: 2500
                running: sidebarWin.visible
                repeat: true
                triggeredOnStart: true
                onTriggered: sidebarWin.refreshStatuses()
            }

            Rectangle {
                id: sidePanel

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 42 * sidebarWin.s
                anchors.rightMargin: 12 * sidebarWin.s
                anchors.bottomMargin: 12 * sidebarWin.s
                width: sidebarWin.panelWidth
	                radius: 10 * sidebarWin.s
                color: Qt.rgba(root.nord1.r, root.nord1.g, root.nord1.b, 0.98)
                border.width: 1
                border.color: root.nord8
                clip: true

                MouseArea {
                    anchors.fill: parent
                }

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 16 * sidebarWin.s
                    contentHeight: sideContent.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    Column {
                        id: sideContent

                        width: parent.width
                        spacing: 14 * sidebarWin.s

                        RowLayout {
                            width: parent.width

                            SectionTitle {
                                overline: "Nord shell"
                                heading: "Control center"
                                scaleFactor: sidebarWin.s
                                Layout.fillWidth: true
                            }

                            IconButton {
                                icon: "󰅖"
                                label: "Close"
                                scaleFactor: sidebarWin.s
                                onActivated: root.sidebarShown = false
                            }
                        }

                        GridLayout {
                            width: parent.width
                            columns: 2
                            rowSpacing: 9 * sidebarWin.s
                            columnSpacing: 9 * sidebarWin.s

                            ActionButton {
                                Layout.fillWidth: true
                                label: sidebarWin.dnd ? "DND on" : "DND off"
                                icon: "󰍡"
                                active: sidebarWin.dnd
                                scaleFactor: sidebarWin.s
                                onActivated: {
                                    root.toggleDnd();
                                    sidebarRefresh.restart();
                                }
                            }

                            ActionButton {
                                Layout.fillWidth: true
                                label: root.keepAwake ? "Awake" : "Idle ok"
                                icon: "󰒳"
                                active: root.keepAwake
                                scaleFactor: sidebarWin.s
                                onActivated: root.keepAwake = !root.keepAwake
                            }

                            ActionButton {
                                Layout.fillWidth: true
                                label: sidebarWin.vpn ? "VPN on" : "VPN off"
                                icon: ""
                                active: sidebarWin.vpn
                                scaleFactor: sidebarWin.s
                                onActivated: {
                                    root.run("if systemctl is-active --quiet wg-quick-wg0.service; then pkexec systemctl stop wg-quick-wg0.service; else pkexec systemctl start wg-quick-wg0.service; fi");
                                    sidebarRefresh.restart();
                                }
                            }

	                            ActionButton {
	                                Layout.fillWidth: true
	                                label: "Clipboard"
	                                icon: "󰅌"
	                                scaleFactor: sidebarWin.s
                                onActivated: {
                                    root.sidebarShown = false;
                                    root.toggle(sidebarWin.mon, "clipboard");
	                                }
		                            }
		                        }

                                Column {
                                    id: sideTrayBlock

                                    width: parent.width
                                    spacing: 8 * sidebarWin.s
                                    visible: sideTray.itemCount > 0

                                    SectionTitle {
                                        width: parent.width
                                        overline: "Tray"
                                        heading: sideTray.itemCount === 1 ? "1 background item" : sideTray.itemCount + " background items"
                                        scaleFactor: sidebarWin.s
                                    }

                                    TrayStrip {
                                        id: sideTray

                                        width: parent.width
                                        scaleFactor: sidebarWin.s
                                        hostWindow: sidebarWin
                                        menuTop: sidePanel.y + 68 * sidebarWin.s
                                        maxStripWidth: parent.width
                                        expandedRows: true
                                    }
                                }
	
		                        Rectangle {
		                            width: parent.width
		                            height: 1
		                            color: root.nord3
		                        }

                                ConnectivityPanel {
                                    width: parent.width
                                    scaleFactor: sidebarWin.s
                                    surfaceActive: sidebarWin.visible
                                    showHeader: true
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: root.nord3
                                }
	
		                        Column {
		                            width: parent.width
		                            spacing: 9 * sidebarWin.s

	                            RowLayout {
	                                width: parent.width

	                                SectionTitle {
	                                    overline: "Notifications"
	                                    heading: sidebarWin.notifications.length === 1 ? "1 item" : sidebarWin.notifications.length + " items"
	                                    scaleFactor: sidebarWin.s
	                                    Layout.fillWidth: true
	                                }

	                                IconButton {
	                                    icon: "󰎟"
	                                    label: "Clear all"
	                                    enabled: sidebarWin.notifications.length > 0
	                                    opacity: enabled ? 1 : 0.35
	                                    scaleFactor: sidebarWin.s
	                                    onActivated: sidebarWin.clearAllNotifications()
	                                }
	                            }

	                            Text {
	                                visible: sidebarWin.notifications.length === 0
	                                width: parent.width
	                                text: "No notifications"
	                                color: root.nord4
	                                font.family: root.uiFont
	                                font.pixelSize: 13 * sidebarWin.s
	                            }

	                            Repeater {
	                                model: sidebarWin.notificationGroups

	                                Rectangle {
	                                    id: notifGroup

	                                    required property var modelData

	                                    width: parent.width
	                                    height: notifGroupContent.implicitHeight + 18 * sidebarWin.s
		                                    radius: 8 * sidebarWin.s
	                                    color: Qt.rgba(root.nord0.r, root.nord0.g, root.nord0.b, 0.55)
	                                    border.width: 1
	                                    border.color: root.nord3

	                                    Column {
	                                        id: notifGroupContent

	                                        anchors.top: parent.top
	                                        anchors.left: parent.left
	                                        anchors.right: parent.right
	                                        anchors.margins: 9 * sidebarWin.s
	                                        spacing: 7 * sidebarWin.s

	                                        RowLayout {
	                                            width: parent.width
	                                            spacing: 7 * sidebarWin.s

	                                            Text {
	                                                Layout.fillWidth: true
	                                                text: notifGroup.modelData.app
	                                                color: root.nord8
	                                                elide: Text.ElideRight
	                                                font.family: root.uiFont
		                                                font.pixelSize: 11 * sidebarWin.s
	                                                font.weight: Font.DemiBold
	                                                font.capitalization: Font.AllUppercase
	                                            }

	                                            Text {
	                                                text: String(notifGroup.modelData.count)
	                                                color: root.nord4
	                                                font.family: root.uiFont
		                                                font.pixelSize: 11 * sidebarWin.s
	                                                font.weight: Font.DemiBold
	                                            }

	                                            IconButton {
	                                                icon: "󰆴"
	                                                label: "Clear group"
	                                                scaleFactor: sidebarWin.s * 0.82
	                                                onActivated: sidebarWin.clearNotificationGroup(notifGroup.modelData)
	                                            }
	                                        }

	                                        Repeater {
	                                            model: notifGroup.modelData.items

	                                            Rectangle {
	                                                id: notifRow

	                                                required property var modelData

	                                                width: notifGroupContent.width
	                                                height: Math.max(42 * sidebarWin.s, notifRowContent.implicitHeight + 14 * sidebarWin.s)
		                                                radius: 6 * sidebarWin.s
	                                                color: notifHover.hovered ? root.nord2 : Qt.rgba(root.nord1.r, root.nord1.g, root.nord1.b, 0.45)
	                                                border.width: modelData.urgency === "critical" ? 1 : 0
	                                                border.color: root.nord11

	                                                HoverHandler {
	                                                    id: notifHover
	                                                }

	                                                RowLayout {
	                                                    id: notifRowContent

	                                                    anchors.fill: parent
	                                                    anchors.margins: 7 * sidebarWin.s
	                                                    spacing: 8 * sidebarWin.s

	                                                    Rectangle {
	                                                        Layout.preferredWidth: 28 * sidebarWin.s
	                                                        Layout.preferredHeight: 28 * sidebarWin.s
		                                                        radius: 5 * sidebarWin.s
	                                                        color: root.nord0
	                                                        border.width: 1
	                                                        border.color: root.nord3
	                                                        clip: true

	                                                        Image {
	                                                            id: notifIcon
	                                                            anchors.fill: parent
	                                                            anchors.margins: 5 * sidebarWin.s
	                                                            source: notifRow.modelData.appIcon.length > 0
	                                                                ? (notifRow.modelData.appIcon.charAt(0) === "/" || notifRow.modelData.appIcon.indexOf("file:") === 0
	                                                                    ? ""
	                                                                    : Quickshell.iconPath(notifRow.modelData.appIcon, ""))
	                                                                : ""
	                                                            sourceSize.width: 48
	                                                            sourceSize.height: 48
	                                                            fillMode: Image.PreserveAspectFit
	                                                            smooth: true
	                                                            visible: source.toString().length > 0
	                                                        }

	                                                        Text {
	                                                            anchors.centerIn: parent
	                                                            visible: !notifIcon.visible
	                                                            text: notifRow.modelData.urgency === "critical" ? "!" : "•"
	                                                            color: notifRow.modelData.urgency === "critical" ? root.nord11 : root.nord8
	                                                            font.family: root.uiFont
		                                                            font.pixelSize: 15 * sidebarWin.s
	                                                            font.weight: Font.Bold
	                                                        }
	                                                    }

	                                                    ColumnLayout {
	                                                        Layout.fillWidth: true
	                                                        spacing: 2 * sidebarWin.s

	                                                        Text {
	                                                            Layout.fillWidth: true
	                                                            text: notifRow.modelData.summary + (notifRow.modelData.live ? "" : "  · history")
	                                                            color: root.nord6
	                                                            elide: Text.ElideRight
	                                                            maximumLineCount: 1
	                                                            font.family: root.uiFont
		                                                            font.pixelSize: 13 * sidebarWin.s
	                                                            font.weight: Font.DemiBold
	                                                            textFormat: Text.PlainText
	                                                        }

	                                                        Text {
	                                                            Layout.fillWidth: true
	                                                            visible: notifRow.modelData.body.length > 0
	                                                            text: notifRow.modelData.body
	                                                            color: root.nord4
	                                                            wrapMode: Text.Wrap
	                                                            maximumLineCount: 2
	                                                            elide: Text.ElideRight
	                                                            font.family: root.uiFont
		                                                            font.pixelSize: 12 * sidebarWin.s
	                                                            textFormat: Text.PlainText
	                                                        }
	                                                    }

	                                                    IconButton {
	                                                        icon: "󰅖"
	                                                        label: "Clear"
	                                                        scaleFactor: sidebarWin.s * 0.82
	                                                        onActivated: sidebarWin.clearNotification(notifRow.modelData)
	                                                    }
	                                                }
	                                            }
	                                        }
	                                    }
	                                }
	                            }
	                        }

	                        Rectangle {
	                            width: parent.width
	                            height: 1
	                            color: root.nord3
	                        }

                        Column {
                            width: parent.width
                            spacing: 9 * sidebarWin.s

                            SectionTitle {
                                width: parent.width
                                overline: "Audio"
                                heading: sidebarWin.volumeText.length > 0 ? "Output " + sidebarWin.volumeText : "Output"
                                scaleFactor: sidebarWin.s
                            }

                            GridLayout {
                                width: parent.width
                                columns: 3
                                rowSpacing: 9 * sidebarWin.s
                                columnSpacing: 9 * sidebarWin.s

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Down"
                                    icon: ""
                                    scaleFactor: sidebarWin.s
                                    onActivated: {
                                        root.run("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-");
                                        sidebarRefresh.restart();
                                    }
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Mute"
                                    icon: "󰖁"
                                    scaleFactor: sidebarWin.s
                                    onActivated: {
                                        root.run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
                                        sidebarRefresh.restart();
                                    }
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Up"
                                    icon: ""
                                    scaleFactor: sidebarWin.s
                                    onActivated: {
                                        root.run("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+");
                                        sidebarRefresh.restart();
                                    }
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: sidebarWin.micText.length > 0 ? "Mic " + sidebarWin.micText : "Mic"
                                    icon: ""
                                    scaleFactor: sidebarWin.s
                                    onActivated: {
                                        root.run("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle");
                                        sidebarRefresh.restart();
                                    }
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Pavu"
                                    icon: "󰕾"
                                    scaleFactor: sidebarWin.s
                                    onActivated: root.run("pavucontrol")
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Wiremix"
                                    icon: ""
                                    scaleFactor: sidebarWin.s
                                    onActivated: root.run("kitty wiremix")
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: root.nord3
                        }

                        Column {
                            width: parent.width
                            spacing: 9 * sidebarWin.s

                            SectionTitle {
                                width: parent.width
                                overline: "Media"
                                heading: sidebarWin.playerTitle
                                scaleFactor: sidebarWin.s
                            }

                            Text {
                                width: parent.width
                                text: sidebarWin.playerArtist.length > 0 ? sidebarWin.playerArtist : "No artist"
                                color: root.nord4
                                elide: Text.ElideRight
                                font.family: root.uiFont
                                font.pixelSize: 13 * sidebarWin.s
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 9 * sidebarWin.s

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Prev"
                                    icon: ""
                                    enabled: sidebarWin.hasPlayer && sidebarWin.player.canGoPrevious
                                    opacity: enabled ? 1 : 0.45
                                    scaleFactor: sidebarWin.s
                                    onActivated: if (sidebarWin.player) sidebarWin.player.previous()
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: sidebarWin.hasPlayer && sidebarWin.player.isPlaying ? "Pause" : "Play"
                                    icon: sidebarWin.hasPlayer && sidebarWin.player.isPlaying ? "" : ""
                                    enabled: sidebarWin.hasPlayer && sidebarWin.player.canTogglePlaying
                                    opacity: enabled ? 1 : 0.45
                                    active: sidebarWin.hasPlayer && sidebarWin.player.isPlaying
                                    scaleFactor: sidebarWin.s
                                    onActivated: if (sidebarWin.player) sidebarWin.player.togglePlaying()
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Next"
                                    icon: ""
                                    enabled: sidebarWin.hasPlayer && sidebarWin.player.canGoNext
                                    opacity: enabled ? 1 : 0.45
                                    scaleFactor: sidebarWin.s
                                    onActivated: if (sidebarWin.player) sidebarWin.player.next()
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: root.nord3
                        }

                        Column {
                            width: parent.width
                            spacing: 9 * sidebarWin.s

		                            SectionTitle {
		                                width: parent.width
		                                overline: "Launch"
		                                heading: "Apps and clipboard"
		                                scaleFactor: sidebarWin.s
		                            }

                            GridLayout {
                                width: parent.width
                                columns: 2
                                rowSpacing: 9 * sidebarWin.s
                                columnSpacing: 9 * sidebarWin.s

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Apps"
                                    icon: ""
                                    scaleFactor: sidebarWin.s
                                    onActivated: root.run("fuzzel")
                                }

		                                ActionButton {
		                                    Layout.fillWidth: true
		                                    label: "Clipboard"
                                    icon: "󰅌"
                                    scaleFactor: sidebarWin.s
                                    onActivated: {
                                        root.sidebarShown = false;
		                                        root.toggle(sidebarWin.mon, "clipboard");
		                                    }
		                                }
		                            }
		                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: root.nord3
                        }

                        GridLayout {
                            width: parent.width
                            columns: 2
                            rowSpacing: 9 * sidebarWin.s
                            columnSpacing: 9 * sidebarWin.s

                            ActionButton {
                                Layout.fillWidth: true
                                label: "Lock"
                                icon: ""
                                scaleFactor: sidebarWin.s
                                onActivated: {
                                    root.sidebarShown = false;
                                    root.run("hyprlock");
                                }
                            }

                            ActionButton {
                                Layout.fillWidth: true
                                label: "Wlogout"
                                icon: "⏻"
                                scaleFactor: sidebarWin.s
                                onActivated: {
                                    root.sidebarShown = false;
                                    root.run("wlogout -b 5 -c 0 -r 0 -m 0 -C /home/berkerz/dotfiles/modules/wlogout/style2.css --protocol layer-shell");
                                }
                            }
                        }
                    }
                }
            }

	            Timer {
	                id: sidebarRefresh
	                interval: 500
	                onTriggered: sidebarWin.refreshStatuses()
	            }

	            Timer {
	                id: notificationRefresh
	                interval: 200
	                onTriggered: if (!notificationProc.running) notificationProc.running = true
	            }
	        }
	    }
	}
