import QtQuick
import qs

// One rounded block on the bar. Every island shares this exact look.
Rectangle {
    id: island

    default property alias content: row.data
    property real padding: Math.round(6 * Theme.s)
    property bool highlighted: false

    signal clicked()
    signal rightClicked()

    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Theme.islandHeight
    radius: Theme.islandRadius
    color: Theme.surface
    border.width: 1
    border.color: highlighted ? Theme.accent : Theme.border

    Behavior on border.color {
        ColorAnimation { duration: Theme.animFast }
    }

    // Sits under the row so children still get their own clicks first.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton)
                island.rightClicked();
            else
                island.clicked();
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        height: parent.height
        spacing: Math.round(2 * Theme.s)
    }
}
