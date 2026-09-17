import QtQuick
import QtQuick.Layouts
import qs

// Inset section inside a popover or the sidebar.
Rectangle {
    id: card

    default property alias content: column.data
    property real padding: Math.round(8 * Theme.s)

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + padding * 2
    radius: Theme.controlRadius + 2
    color: Theme.alpha(Theme.shell, 0.55)

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: card.padding
        spacing: Math.round(4 * Theme.s)
    }
}
