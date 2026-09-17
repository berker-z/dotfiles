import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.components

// Output and input sliders. Clicking the icon mutes.
ColumnLayout {
    spacing: Theme.gap

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Math.round(3 * Theme.s)

        Text {
            Layout.fillWidth: true
            text: Audio.sinkName
            color: Theme.fgMuted
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
        }

        Slider {
            Layout.fillWidth: true
            icon: Audio.icon
            text: Audio.volumePct + "%"
            value: Audio.volume
            muted: Audio.muted
            enabled: Audio.sinkReady
            onMoved: function(v) { Audio.setVolume(v); }
            onIconClicked: Audio.toggleMute()
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Math.round(3 * Theme.s)

        Text {
            Layout.fillWidth: true
            text: Audio.sourceName
            color: Theme.fgMuted
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
        }

        Slider {
            Layout.fillWidth: true
            icon: Audio.micMuted ? "󰍭" : "󰍬"
            text: Audio.micPct + "%"
            value: Audio.micVolume
            muted: Audio.micMuted
            enabled: Audio.sourceReady
            onMoved: function(v) { Audio.setMicVolume(v); }
            onIconClicked: Audio.toggleMicMute()
        }
    }
}
