import QtQuick
import QtQuick.Layouts
import qs

// Popover / section header: a title, an optional muted subtitle, and room
// on the right for buttons (place them as children).
RowLayout {
    id: header

    property string title: ""
    property string subtitle: ""
    default property alias trailing: trailingRow.data

    spacing: Theme.gap

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Math.round(1 * Theme.s)

        Text {
            Layout.fillWidth: true
            text: header.title
            color: Theme.fg
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontLarge
            font.weight: Font.Bold
        }

        Text {
            Layout.fillWidth: true
            visible: header.subtitle.length > 0
            text: header.subtitle
            color: Theme.fgMuted
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
        }
    }

    Row {
        id: trailingRow
        Layout.alignment: Qt.AlignVCenter
        spacing: Math.round(4 * Theme.s)
    }
}
