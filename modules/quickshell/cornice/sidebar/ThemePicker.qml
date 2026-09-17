import QtQuick
import QtQuick.Layouts
import qs

// Palette swatches. The selected one gets the accent ring.
GridLayout {
    columns: 2
    rowSpacing: Math.round(6 * Theme.s)
    columnSpacing: Math.round(6 * Theme.s)

    Repeater {
        model: Theme.options

        Rectangle {
            id: choice

            required property var modelData

            readonly property var pal: Theme.palettes[modelData.id]
            readonly property bool selected: Theme.name === modelData.id

            Layout.fillWidth: true
            implicitHeight: Math.round(38 * Theme.s)
            radius: Theme.controlRadius
            color: area.containsMouse ? Theme.hover : Theme.raised
            border.width: selected ? 1 : 0
            border.color: Theme.accent

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Math.round(8 * Theme.s)
                anchors.rightMargin: Math.round(8 * Theme.s)
                spacing: Theme.gap

                Rectangle {
                    Layout.preferredWidth: Math.round(38 * Theme.s)
                    Layout.preferredHeight: Math.round(20 * Theme.s)
                    radius: Math.round(4 * Theme.s)
                    color: choice.pal.shell
                    clip: true

                    Row {
                        anchors.fill: parent
                        anchors.margins: Math.round(3 * Theme.s)
                        spacing: Math.round(2 * Theme.s)

                        Repeater {
                            model: [choice.pal.accent, choice.pal.green, choice.pal.yellow, choice.pal.red, choice.pal.purple]

                            Rectangle {
                                required property var modelData
                                width: (parent.width - parent.spacing * 4) / 5
                                height: parent.height
                                radius: 2
                                color: modelData
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: choice.modelData.label
                    color: Theme.fg
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    font.weight: choice.selected ? Font.Bold : Font.DemiBold
                }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Theme.set(choice.modelData.id)
            }
        }
    }
}
