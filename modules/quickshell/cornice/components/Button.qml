import QtQuick
import qs

// The one button. Icon-only when `label` is empty, icon + label otherwise.
// `active` is the pressed-in look used for "this popover is open" and for
// on/off states; `flat` drops the resting background for bar and header use.
Rectangle {
    id: button

    property string icon: ""
    property string label: ""
    property string tooltip: ""
    property bool active: false
    property bool flat: false
    property bool danger: false
    property bool fill: false
    property color tint: "transparent"
    readonly property bool tinted: tint.a > 0
    property real size: Theme.controlHeight
    property int iconSize: Theme.iconSize
    property int labelSize: Theme.fontSize

    readonly property bool hovered: area.containsMouse
    readonly property bool iconOnly: label.length === 0

    signal clicked(var mouse)
    signal wheel(var wheel)

    implicitWidth: iconOnly ? size : content.implicitWidth + Theme.pad * 1.5
    implicitHeight: size
    radius: Theme.controlRadius
    opacity: enabled ? 1 : 0.4

    color: active ? Theme.accentStrong
        : hovered ? Theme.hover
        : flat ? "transparent" : Theme.raised

    Behavior on color {
        ColorAnimation { duration: Theme.animFast }
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Math.round(6 * Theme.s)

        Text {
            visible: button.icon.length > 0
            anchors.verticalCenter: parent.verticalCenter
            text: button.icon
            color: button.danger ? Theme.red : button.tinted ? button.tint : (button.active || button.hovered ? Theme.fg : Theme.fgMuted)
            font.family: Theme.font
            font.pixelSize: button.iconSize
        }

        Text {
            visible: !button.iconOnly
            anchors.verticalCenter: parent.verticalCenter
            text: button.label
            color: button.danger ? Theme.red : button.tinted ? button.tint : Theme.fg
            font.family: Theme.font
            font.pixelSize: button.labelSize
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) { button.clicked(mouse); }
        onWheel: function(w) { button.wheel(w); }
    }
}
