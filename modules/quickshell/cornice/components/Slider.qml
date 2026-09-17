import QtQuick
import qs

// Horizontal slider. Click or drag sets, wheel nudges. Optional leading icon
// (clickable, e.g. to mute) and trailing value text.
Item {
    id: slider

    property real value: 0
    property string icon: ""
    property string text: ""
    property bool muted: false
    property real wheelStep: 0.05

    signal moved(real value)
    signal iconClicked()

    implicitHeight: Math.round(24 * Theme.s)

    readonly property real iconW: icon.length > 0 ? Math.round(26 * Theme.s) : 0
    readonly property real textW: text.length > 0 ? Math.round(38 * Theme.s) : 0

    Text {
        id: iconText
        visible: slider.icon.length > 0
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: slider.iconW
        text: slider.icon
        color: slider.muted ? Theme.fgMuted : Theme.accent
        font.family: Theme.font
        font.pixelSize: Math.round(15 * Theme.s)

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            cursorShape: Qt.PointingHandCursor
            onClicked: slider.iconClicked()
        }
    }

    Item {
        id: track
        anchors.left: parent.left
        anchors.leftMargin: slider.iconW
        anchors.right: parent.right
        anchors.rightMargin: slider.textW
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height

        readonly property real handle: Math.round(14 * Theme.s)
        readonly property real fillW: handle / 2 + (width - handle) * Math.max(0, Math.min(1, slider.value))

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.round(6 * Theme.s)
            radius: height / 2
            color: Theme.shell
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: track.fillW
            height: Math.round(6 * Theme.s)
            radius: height / 2
            color: slider.muted ? Theme.border : Theme.accent

            Behavior on width {
                enabled: !area.pressed
                NumberAnimation { duration: 80 }
            }
        }

        Rectangle {
            x: track.fillW - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: track.handle
            height: track.handle
            radius: width / 2
            color: Theme.fg
            border.width: 1
            border.color: Theme.alpha(Theme.shell, 0.5)
            scale: area.pressed ? 1.15 : (area.containsMouse ? 1.08 : 1)

            Behavior on scale {
                NumberAnimation { duration: Theme.animFast }
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            function apply(x) {
                var v = (x - track.handle / 2) / Math.max(1, track.width - track.handle);
                slider.moved(Math.max(0, Math.min(1, v)));
            }

            onPressed: function(mouse) { apply(mouse.x); }
            onPositionChanged: function(mouse) { if (pressed) apply(mouse.x); }
            onWheel: function(w) {
                slider.moved(Math.max(0, Math.min(1, slider.value + (w.angleDelta.y > 0 ? slider.wheelStep : -slider.wheelStep))));
            }
        }
    }

    Text {
        visible: slider.text.length > 0
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: slider.textW
        horizontalAlignment: Text.AlignRight
        text: slider.text
        color: Theme.fgMuted
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
        font.features: { "tnum": 1 }
    }
}
