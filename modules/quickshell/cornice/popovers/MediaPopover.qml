import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.components

// Now playing + the two audio sliders. Same content the sidebar shows, so
// this is the place for quick control and the sidebar just embeds it.
Popover {
    id: pop

    implicitWidth: Math.round(360 * Theme.s)

    NowPlaying {
        Layout.fillWidth: true
    }

    Divider {}

    AudioControls {
        Layout.fillWidth: true
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.gap

        Button {
            Layout.fillWidth: true
            icon: "󰕾"
            label: "Mixer"
            onClicked: {
                Panels.closeAll();
                Quickshell.execDetached(["pavucontrol"]);
            }
        }

        Button {
            Layout.fillWidth: true
            icon: ""
            label: "Wiremix"
            onClicked: {
                Panels.closeAll();
                Quickshell.execDetached(["kitty", "wiremix"]);
            }
        }
    }
}
