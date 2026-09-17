import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.components

// Notifications grouped by app, newest group first.
ColumnLayout {
    spacing: Theme.gap

    Repeater {
        model: Notifs.groups

        Card {
            id: group

            required property var modelData

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Math.round(4 * Theme.s)
                spacing: Theme.gap

                Text {
                    Layout.fillWidth: true
                    text: group.modelData.app
                    color: Theme.accent
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    font.weight: Font.Bold
                    font.capitalization: Font.AllUppercase
                }

                Text {
                    text: group.modelData.items.length
                    color: Theme.fgMuted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                }

                Button {
                    icon: "󰅖"
                    flat: true
                    size: Math.round(24 * Theme.s)
                    onClicked: Notifs.dismissGroup(group.modelData)
                }
            }

            Repeater {
                model: group.modelData.items

                Rectangle {
                    id: note

                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: body.implicitHeight + Math.round(16 * Theme.s)
                    radius: Theme.controlRadius
                    color: hover.hovered ? Theme.hover : Theme.alpha(Theme.raised, 0.6)
                    border.width: modelData.urgency === "critical" ? 1 : 0
                    border.color: Theme.red

                    HoverHandler { id: hover }

                    RowLayout {
                        id: body
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Math.round(8 * Theme.s)
                        spacing: Theme.gap

                        Rectangle {
                            Layout.preferredWidth: Math.round(28 * Theme.s)
                            Layout.preferredHeight: Math.round(28 * Theme.s)
                            Layout.alignment: Qt.AlignTop
                            radius: Math.round(6 * Theme.s)
                            color: Theme.shell
                            clip: true

                            Image {
                                id: appIcon
                                anchors.fill: parent
                                anchors.margins: Math.round(4 * Theme.s)
                                source: {
                                    var ic = note.modelData.icon;
                                    if (ic.length === 0)
                                        return "";
                                    if (ic.charAt(0) === "/")
                                        return "file://" + ic;
                                    if (ic.indexOf("file:") === 0)
                                        return ic;
                                    return Quickshell.iconPath(ic, "");
                                }
                                sourceSize.width: 48
                                sourceSize.height: 48
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !appIcon.visible
                                text: note.modelData.urgency === "critical" ? "!" : "󰂚"
                                color: note.modelData.urgency === "critical" ? Theme.red : Theme.fgMuted
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Math.round(2 * Theme.s)

                            Text {
                                Layout.fillWidth: true
                                text: note.modelData.summary
                                color: Theme.fg
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                                font.weight: Font.DemiBold
                                textFormat: Text.PlainText
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: note.modelData.body.length > 0
                                text: note.modelData.body
                                color: Theme.fgMuted
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSmall
                                textFormat: Text.PlainText
                            }
                        }

                        Button {
                            Layout.alignment: Qt.AlignTop
                            icon: "󰅖"
                            flat: true
                            size: Math.round(24 * Theme.s)
                            opacity: hover.hovered ? 1 : 0.4
                            onClicked: Notifs.dismiss(note.modelData)
                        }
                    }
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.margins: Math.round(4 * Theme.s)
        visible: Notifs.count === 0
        text: "No notifications"
        color: Theme.fgMuted
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
    }
}
