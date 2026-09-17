pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default sink and source straight from Pipewire. No wpctl polling: volume
// and mute are live bindings, and setting them writes through immediately.
Singleton {
    id: audio

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property bool sinkReady: sink !== null && sink.audio !== null
    readonly property bool sourceReady: source !== null && source.audio !== null

    readonly property real volume: sinkReady ? sink.audio.volume : 0
    readonly property bool muted: sinkReady ? sink.audio.muted : false
    readonly property int volumePct: Math.round(volume * 100)

    readonly property real micVolume: sourceReady ? source.audio.volume : 0
    readonly property bool micMuted: sourceReady ? source.audio.muted : false
    readonly property int micPct: Math.round(micVolume * 100)

    readonly property string sinkName: sinkReady ? (sink.description || sink.nickname || sink.name) : "No output"
    readonly property string sourceName: sourceReady ? (source.description || source.nickname || source.name) : "No input"

    readonly property string icon: muted || volumePct === 0 ? "󰝟" : (volumePct < 34 ? "󰕿" : (volumePct < 67 ? "󰖀" : "󰕾"))

    PwObjectTracker {
        objects: [audio.sink, audio.source].filter(function(o) { return o !== null; })
    }

    function setVolume(v) {
        if (!sinkReady)
            return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, v));
    }

    function step(delta) {
        setVolume(volume + delta);
    }

    function toggleMute() {
        if (sinkReady)
            sink.audio.muted = !sink.audio.muted;
    }

    function setMicVolume(v) {
        if (!sourceReady)
            return;
        source.audio.muted = false;
        source.audio.volume = Math.max(0, Math.min(1, v));
    }

    function toggleMicMute() {
        if (sourceReady)
            source.audio.muted = !source.audio.muted;
    }
}
