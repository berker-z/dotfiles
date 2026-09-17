pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Spotify, and only Spotify. Browsers register MPRIS players for every
// tab with a <video>, and none of that belongs on the bar.
Singleton {
    id: media

    readonly property var player: {
        var list = Mpris.players.values || [];
        for (var i = 0; i < list.length; i++)
            if (isSpotify(list[i]))
                return list[i];
        return null;
    }

    readonly property bool active: player !== null
    readonly property bool playing: active && player.isPlaying
    readonly property string title: active && player.trackTitle ? String(player.trackTitle) : ""
    readonly property string artist: {
        if (!active)
            return "";
        var a = player.trackArtists;
        if (a && typeof a.join === "function" && a.length > 0)
            return a.join(", ");
        if (a && String(a).length > 0)
            return String(a);
        return player.trackArtist ? String(player.trackArtist) : "";
    }
    readonly property string album: active && player.trackAlbum ? String(player.trackAlbum) : ""
    readonly property string artUrl: active && player.trackArtUrl ? String(player.trackArtUrl) : ""
    readonly property string label: title.length > 0 ? (artist.length > 0 ? artist + " — " + title : title) : ""

    readonly property real length: active && player.length > 0 ? player.length : 0
    readonly property real position: active ? player.position : 0

    function isSpotify(p) {
        if (!p)
            return false;
        return [p.identity || "", p.desktopEntry || "", p.dbusName || ""].join(" ").toLowerCase().indexOf("spotify") !== -1;
    }

    function toggle() {
        if (active && player.canTogglePlaying)
            player.togglePlaying();
        else
            Quickshell.execDetached(["spotify"]);
    }

    function next() {
        if (active && player.canGoNext)
            player.next();
    }

    function previous() {
        if (active && player.canGoPrevious)
            player.previous();
    }

    function seek(fraction) {
        if (active && player.canSeek && length > 0)
            player.position = fraction * length;
    }

    function formatTime(seconds) {
        seconds = Math.max(0, Math.floor(seconds));
        var m = Math.floor(seconds / 60);
        var s = seconds % 60;
        return m + ":" + (s < 10 ? "0" : "") + s;
    }
}
