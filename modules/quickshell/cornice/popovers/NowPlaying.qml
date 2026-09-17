import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.components

// Album art, track, progress, transport. Shared by the media popover and
// the sidebar.
ColumnLayout {
    id: np

    spacing: Theme.gap

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.pad

        Rectangle {
            Layout.preferredWidth: Math.round(56 * Theme.s)
            Layout.preferredHeight: Math.round(56 * Theme.s)
            radius: Theme.controlRadius
            color: Theme.shell
            clip: true

            Image {
                id: art
                anchors.fill: parent
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: !art.visible
                text: "󰎆"
                color: Theme.fgMuted
                font.family: Theme.font
                font.pixelSize: Math.round(22 * Theme.s)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Math.round(2 * Theme.s)

            Text {
                Layout.fillWidth: true
                text: Media.active ? (Media.title.length > 0 ? Media.title : "Nothing playing") : "Spotify not running"
                color: Theme.fg
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontLarge
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                text: Media.artist.length > 0 ? Media.artist : "Open Spotify to start"
                color: Theme.fgMuted
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }

            Text {
                Layout.fillWidth: true
                visible: Media.album.length > 0
                text: Media.album
                color: Theme.alpha(Theme.fgMuted, 0.7)
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: Media.active && Media.length > 0
        spacing: Theme.gap

        Text {
            text: Media.formatTime(Media.position)
            color: Theme.fgMuted
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            font.features: { "tnum": 1 }
        }

        Slider {
            Layout.fillWidth: true
            value: Media.length > 0 ? Media.position / Media.length : 0
            wheelStep: 0.02
            onMoved: function(v) { Media.seek(v); }
        }

        Text {
            text: Media.formatTime(Media.length)
            color: Theme.fgMuted
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            font.features: { "tnum": 1 }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.gap

        Button {
            icon: "󰒮"
            enabled: Media.active && Media.player.canGoPrevious
            onClicked: Media.previous()
        }

        Button {
            icon: Media.playing ? "󰏤" : "󰐊"
            active: Media.playing
            size: Math.round(36 * Theme.s)
            iconSize: Math.round(17 * Theme.s)
            implicitWidth: Math.round(56 * Theme.s)
            onClicked: Media.toggle()
        }

        Button {
            icon: "󰒭"
            enabled: Media.active && Media.player.canGoNext
            onClicked: Media.next()
        }
    }

    // Position only ticks while a surface showing it is open.
    Timer {
        interval: 1000
        running: Media.active && Media.playing
        repeat: true
        onTriggered: if (Media.player) Media.player.positionChanged()
    }
}
