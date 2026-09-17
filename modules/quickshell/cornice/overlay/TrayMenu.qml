import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.components

// DBus menu for a tray item, rendered as one flat list. Submenus expand in
// place under their parent row instead of opening another popup.
Popover {
    id: menu

    required property var handle
    property int expanded: -1

    implicitWidth: Math.round(240 * Theme.s)
    maxHeight: Math.round(600 * Theme.s)

    QsMenuOpener {
        id: opener
        menu: menu.handle
    }

    component MenuRow: Item {
        id: row

        required property var entry
        property real indent: 0
        property bool open: false

        signal activated()

        readonly property bool separator: entry && entry.isSeparator
        readonly property bool checkable: entry && (entry.buttonType === QsMenuButtonType.CheckBox || entry.buttonType === QsMenuButtonType.RadioButton)
        readonly property bool checked: entry && entry.checkState === Qt.Checked

        Layout.fillWidth: true
        implicitHeight: separator ? Math.round(9 * Theme.s) : Math.round(32 * Theme.s)

        Rectangle {
            visible: row.separator
            anchors.centerIn: parent
            width: parent.width - Math.round(12 * Theme.s)
            height: 1
            color: Theme.border
        }

        Rectangle {
            visible: !row.separator
            anchors.fill: parent
            anchors.leftMargin: row.indent
            radius: Theme.controlRadius
            color: area.containsMouse && row.entry.enabled ? Theme.hover : "transparent"
            opacity: row.entry && row.entry.enabled ? 1 : 0.4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Math.round(9 * Theme.s)
                anchors.rightMargin: Math.round(9 * Theme.s)
                spacing: Math.round(8 * Theme.s)

                Rectangle {
                    visible: row.checkable
                    Layout.preferredWidth: Math.round(12 * Theme.s)
                    Layout.preferredHeight: Math.round(12 * Theme.s)
                    radius: row.entry.buttonType === QsMenuButtonType.RadioButton ? width / 2 : Math.round(3 * Theme.s)
                    color: row.checked ? Theme.accent : "transparent"
                    border.width: 1
                    border.color: row.checked ? Theme.accent : Theme.fgMuted
                }

                Image {
                    visible: status === Image.Ready
                    Layout.preferredWidth: Math.round(15 * Theme.s)
                    Layout.preferredHeight: Math.round(15 * Theme.s)
                    source: row.entry && row.entry.icon ? row.entry.icon : ""
                    sourceSize.width: 30
                    sourceSize.height: 30
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Text {
                    Layout.fillWidth: true
                    text: row.entry ? row.entry.text : ""
                    color: Theme.fg
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }

                Text {
                    visible: row.entry && row.entry.hasChildren
                    text: row.open ? "󰅀" : "󰅂"
                    color: Theme.fgMuted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                enabled: row.entry && row.entry.enabled
                cursorShape: Qt.PointingHandCursor
                onClicked: row.activated()
            }
        }
    }

    Flickable {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(list.implicitHeight, menu.maxHeight - Theme.pad * 2)
        contentHeight: list.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        ColumnLayout {
            id: list
            width: parent.width
            spacing: 1

            Repeater {
                model: opener.children ? opener.children.values : []

                ColumnLayout {
                    id: group

                    required property var modelData
                    required property int index

                    readonly property bool open: menu.expanded === index

                    Layout.fillWidth: true
                    spacing: 1

                    MenuRow {
                        entry: group.modelData
                        open: group.open
                        onActivated: {
                            if (group.modelData.hasChildren) {
                                menu.expanded = group.open ? -1 : group.index;
                            } else {
                                group.modelData.triggered();
                                Panels.closeAll();
                            }
                        }
                    }

                    QsMenuOpener {
                        id: childOpener
                        menu: group.open ? group.modelData : null
                    }

                    Repeater {
                        model: childOpener.children ? childOpener.children.values : []

                        MenuRow {
                            required property var modelData
                            entry: modelData
                            indent: Math.round(16 * Theme.s)
                            onActivated: {
                                if (!modelData.hasChildren) {
                                    modelData.triggered();
                                    Panels.closeAll();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
