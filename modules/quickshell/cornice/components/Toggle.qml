import QtQuick
import qs

// Sidebar-style toggle tile: icon, name, and a one-word state underneath.
// Checked tiles fill with the strong accent so on/off reads at a glance.
Rectangle {
    id: toggle

    property string icon: ""
    property string label: ""
    property string stateText: checked ? "On" : "Off"
    property bool checked: false
    property bool busy: false

    signal clicked()

    implicitHeight: Math.round(50 * Theme.s)
    radius: Theme.controlRadius
    color: checked ? Theme.accentStrong : (area.containsMouse ? Theme.hover : Theme.raised)
    opacity: enabled ? 1 : 0.4

    Behavior on color {
        ColorAnimation { duration: Theme.animFast }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.pad
        anchors.rightMargin: Theme.pad
        spacing: Math.round(10 * Theme.s)

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: toggle.icon
            color: toggle.checked ? Theme.fg : Theme.accent
            font.family: Theme.font
            font.pixelSize: Math.round(17 * Theme.s)
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - parent.spacing - Math.round(20 * Theme.s)
            spacing: Math.round(1 * Theme.s)

            Text {
                width: parent.width
                text: toggle.label
                color: Theme.fg
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: toggle.busy ? "…" : toggle.stateText
                color: toggle.checked ? Theme.alpha(Theme.fg, 0.8) : Theme.fgMuted
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: toggle.clicked()
    }
}
