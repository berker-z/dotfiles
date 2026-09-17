import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.components

// cliphist browser. Type to filter, arrows to move, Enter copies, Delete
// removes, right click removes.
Popover {
    id: pop

    property string query: ""
    property int selected: 0

    readonly property var results: {
        var q = query.trim().toLowerCase();
        var src = Clipboard.entries;
        if (q.length === 0)
            return src;
        return src.filter(function(e) {
            return ((e.preview || "") + " " + (e.meta || "")).toLowerCase().indexOf(q) !== -1;
        });
    }

    implicitWidth: Math.round(460 * Theme.s)

    function move(delta) {
        if (results.length === 0)
            return;
        selected = Math.max(0, Math.min(results.length - 1, selected + delta));
        list.positionViewAtIndex(selected, ListView.Contain);
    }

    function copySelected() {
        if (results.length > 0)
            Clipboard.copy(results[selected], Panels.closeAll);
    }

    onQueryChanged: selected = 0
    onResultsChanged: selected = Math.max(0, Math.min(selected, results.length - 1))

    Component.onCompleted: {
        Clipboard.refresh();
        Qt.callLater(search.forceActiveFocus);
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.gap

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(34 * Theme.s)
            radius: Theme.controlRadius
            color: Theme.shell
            border.width: 1
            border.color: search.activeFocus ? Theme.accent : Theme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Math.round(10 * Theme.s)
                anchors.rightMargin: Math.round(10 * Theme.s)
                spacing: Theme.gap

                Text {
                    text: ""
                    color: Theme.accent
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }

                TextInput {
                    id: search
                    Layout.fillWidth: true
                    color: Theme.fg
                    selectionColor: Theme.accentStrong
                    selectedTextColor: Theme.fg
                    clip: true
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    onTextEdited: pop.query = text
                    Keys.onPressed: function(e) {
                        if (e.key === Qt.Key_Down) { pop.move(1); e.accepted = true; }
                        else if (e.key === Qt.Key_Up) { pop.move(-1); e.accepted = true; }
                        else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { pop.copySelected(); e.accepted = true; }
                        else if (e.key === Qt.Key_Delete && pop.results.length > 0) { Clipboard.remove(pop.results[pop.selected]); e.accepted = true; }
                    }

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: search.text.length === 0
                        text: "Search clipboard"
                        color: Theme.alpha(Theme.fgMuted, 0.6)
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                    }
                }

                Text {
                    text: Clipboard.status.length > 0 ? Clipboard.status : pop.results.length + "/" + Clipboard.entries.length
                    color: Clipboard.status === "Copy failed" ? Theme.red : Theme.fgMuted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    font.features: { "tnum": 1 }
                }
            }
        }

        Button {
            icon: "󰑓"
            flat: true
            onClicked: Clipboard.refresh()
        }

        Button {
            icon: "󰆴"
            flat: true
            danger: true
            onClicked: Clipboard.wipe()
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(list.contentHeight, pop.maxHeight - Theme.pad * 2 - Math.round(44 * Theme.s))
        Layout.minimumHeight: Math.round(60 * Theme.s)

        Text {
            anchors.centerIn: parent
            visible: pop.results.length === 0
            text: pop.query.length > 0 ? "No matches" : "Clipboard history is empty"
            color: Theme.fgMuted
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
        }

        ListView {
            id: list
            anchors.fill: parent
            clip: true
            spacing: Math.round(2 * Theme.s)
            boundsBehavior: Flickable.StopAtBounds
            model: pop.results

            delegate: ListRow {
                id: row

                required property var modelData
                required property int index

                width: list.width
                implicitHeight: modelData.binary ? Math.round(56 * Theme.s) : Math.round(40 * Theme.s)
                icon: modelData.binary ? "" : "󰆏"
                title: modelData.preview
                subtitle: modelData.meta
                selected: index === pop.selected
                onEntered: pop.selected = index
                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton)
                        Clipboard.remove(row.modelData);
                    else
                        Clipboard.copy(row.modelData, Panels.closeAll);
                }

                leading: Rectangle {
                    visible: row.modelData.binary
                    width: visible ? Math.round(64 * Theme.s) : 0
                    height: visible ? Math.round(44 * Theme.s) : 0
                    radius: Math.round(5 * Theme.s)
                    color: Theme.shell
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: row.modelData.binary ? Clipboard.thumb(row.modelData.id) : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }
                }

                Button {
                    icon: "󰅖"
                    flat: true
                    size: Math.round(24 * Theme.s)
                    opacity: row.hovered || row.selected ? 1 : 0
                    onClicked: Clipboard.remove(row.modelData)
                }
            }
        }
    }
}
