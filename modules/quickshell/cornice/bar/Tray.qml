import QtQuick
import Quickshell.Services.SystemTray
import qs
import qs.services

// Tray icons, plain, no slots. Left click activates, right click (or left
// click on menu-only items) opens the item's menu in the overlay.
Row {
    id: tray

    required property string monitor

    readonly property var items: (SystemTray.items.values || []).filter(function(item) {
        if (!item)
            return false;
        var ident = [item.id || "", item.title || "", item.tooltipTitle || ""].join(" ").toLowerCase();
        return ident.indexOf("spotify") === -1;
    })

    anchors.verticalCenter: parent.verticalCenter
    spacing: Math.round(2 * Theme.s)
    visible: items.length > 0

    Repeater {
        model: tray.items

        Rectangle {
            id: slot

            required property var modelData

            width: Math.round(24 * Theme.s)
            height: Math.round(24 * Theme.s)
            radius: Math.round(6 * Theme.s)
            color: area.containsMouse || (Panels.trayMenu !== null && Panels.trayMenu === slot.modelData.menu) ? Theme.hover : "transparent"
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: icon
                anchors.centerIn: parent
                width: Math.round(15 * Theme.s)
                height: width
                source: slot.modelData.icon || ""
                sourceSize.width: 32
                sourceSize.height: 32
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                mipmap: true
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: !icon.visible
                text: "•"
                color: Theme.accent
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                function openMenu() {
                    if (!slot.modelData.hasMenu)
                        return;
                    var p = slot.mapToItem(null, slot.width / 2, 0);
                    Panels.openTrayMenu(tray.monitor, slot.modelData.menu, p.x);
                }

                onClicked: function(mouse) {
                    var item = slot.modelData;
                    if (mouse.button === Qt.RightButton || item.onlyMenu)
                        openMenu();
                    else if (mouse.button === Qt.MiddleButton)
                        item.secondaryActivate();
                    else
                        item.activate();
                }
                onWheel: function(w) { slot.modelData.scroll(w.angleDelta.y, false); }
            }
        }
    }
}
