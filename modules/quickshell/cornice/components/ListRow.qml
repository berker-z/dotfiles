import QtQuick
import QtQuick.Layouts
import qs

// One row in any list (networks, devices, clipboard entries, notifications):
// leading glyph, title + subtitle, trailing text or controls.
Rectangle {
    id: row

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property string trailingText: ""
    property bool selected: false
    property bool highlighted: false
    property real leadingWidth: Math.round(20 * Theme.s)
    default property alias trailing: trailingRow.data
    property alias leading: leadingSlot.data

    readonly property bool hovered: area.containsMouse

    signal clicked(var mouse)
    signal entered()

    implicitHeight: Math.round(40 * Theme.s)
    radius: Theme.controlRadius
    color: selected ? Theme.alpha(Theme.accentStrong, 0.5)
        : hovered || highlighted ? Theme.hover
        : "transparent"

    Behavior on color {
        ColorAnimation { duration: Theme.animFast }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) { row.clicked(mouse); }
        onEntered: row.entered()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Math.round(10 * Theme.s)
        anchors.rightMargin: Math.round(10 * Theme.s)
        spacing: Math.round(8 * Theme.s)

        Item {
            id: leadingSlot
            visible: children.length > 0
            Layout.preferredWidth: childrenRect.width
            Layout.preferredHeight: childrenRect.height
        }

        Text {
            visible: row.icon.length > 0
            Layout.preferredWidth: row.leadingWidth
            horizontalAlignment: Text.AlignHCenter
            text: row.icon
            color: row.selected ? Theme.fg : Theme.accent
            font.family: Theme.font
            font.pixelSize: Math.round(15 * Theme.s)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: row.title
                color: Theme.fg
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                font.weight: row.selected ? Font.DemiBold : Font.Normal
            }

            Text {
                Layout.fillWidth: true
                visible: row.subtitle.length > 0
                text: row.subtitle
                color: row.selected ? Theme.alpha(Theme.fg, 0.75) : Theme.fgMuted
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
            }
        }

        Text {
            visible: row.trailingText.length > 0
            text: row.trailingText
            color: Theme.fgMuted
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            font.features: { "tnum": 1 }
        }

        Row {
            id: trailingRow
            Layout.alignment: Qt.AlignVCenter
            spacing: Math.round(4 * Theme.s)
        }
    }
}
