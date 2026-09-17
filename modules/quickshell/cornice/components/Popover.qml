import QtQuick
import QtQuick.Layouts
import qs

// Frame every popover uses. Children go into a ColumnLayout with the
// standard padding; height follows content unless `maxHeight` clips it.
Rectangle {
    id: popover

    property real maxHeight: 0
    default property alias content: column.data

    readonly property real contentHeight: column.implicitHeight + Theme.pad * 2

    implicitHeight: maxHeight > 0 ? Math.min(maxHeight, contentHeight) : contentHeight
    radius: Theme.popoverRadius
    color: Theme.surface
    border.width: 1
    border.color: Theme.border
    clip: true

    // Swallow clicks so they never reach the click-outside layer below.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onWheel: function(w) { w.accepted = true; }
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.pad
        spacing: Math.round(10 * Theme.s)
    }
}
