import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.components

// Same five actions as the wlogout layout in modules/wlogout/default.nix.
Popover {
    id: pop

    implicitWidth: Math.round(400 * Theme.s)

    function run(cmd) {
        Panels.closeAll();
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    component PowerTile: Rectangle {
        id: tile

        property string icon: ""
        property string label: ""
        property bool danger: false

        signal clicked()

        Layout.fillWidth: true
        implicitHeight: Math.round(68 * Theme.s)
        radius: Theme.controlRadius
        color: area.containsMouse ? (danger ? Theme.alpha(Theme.red, 0.25) : Theme.hover) : Theme.raised

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Column {
            anchors.centerIn: parent
            spacing: Math.round(5 * Theme.s)

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tile.icon
                color: tile.danger ? Theme.red : Theme.accent
                font.family: Theme.font
                font.pixelSize: Math.round(20 * Theme.s)
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tile.label
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.clicked()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.gap

        PowerTile { icon: "󰌾"; label: "Lock"; onClicked: pop.run("hyprlock") }
        PowerTile { icon: "󰗽"; label: "Logout"; onClicked: pop.run("loginctl kill-session \"$XDG_SESSION_ID\"") }
        PowerTile { icon: "󰒲"; label: "Suspend"; onClicked: pop.run("systemctl suspend") }
        PowerTile { icon: "󰜉"; label: "Reboot"; danger: true; onClicked: pop.run("systemctl reboot") }
        PowerTile { icon: "⏻"; label: "Shutdown"; danger: true; onClicked: pop.run("systemctl poweroff") }
    }
}
