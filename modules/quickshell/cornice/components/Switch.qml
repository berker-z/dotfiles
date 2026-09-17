import QtQuick
import qs

// Small inline on/off switch for list headers (Wi-Fi, Bluetooth).
Rectangle {
    id: sw

    property bool checked: false

    signal toggled()

    implicitWidth: Math.round(40 * Theme.s)
    implicitHeight: Math.round(22 * Theme.s)
    radius: height / 2
    color: checked ? Theme.accentStrong : Theme.shell
    border.width: 1
    border.color: checked ? Theme.accentStrong : Theme.border
    opacity: enabled ? 1 : 0.4

    Behavior on color {
        ColorAnimation { duration: Theme.animFast }
    }

    Rectangle {
        readonly property real inset: Math.round(3 * Theme.s)
        width: parent.height - inset * 2
        height: width
        radius: width / 2
        x: sw.checked ? sw.width - width - inset : inset
        anchors.verticalCenter: parent.verticalCenter
        color: sw.checked ? Theme.fg : Theme.fgMuted

        Behavior on x {
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: sw.toggled()
    }
}
