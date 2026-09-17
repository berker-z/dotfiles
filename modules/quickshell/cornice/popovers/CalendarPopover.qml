import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components

Popover {
    id: cal

    readonly property var today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()

    readonly property var locale: Qt.locale("en_US")
    readonly property int offset: (new Date(year, month, 1).getDay() + 6) % 7
    // Not "onToday": names matching on[A-Z]* are parsed as signal handlers.
    readonly property bool viewingToday: cal.year === cal.today.getFullYear() && cal.month === cal.today.getMonth()

    implicitWidth: Math.round(320 * Theme.s)

    function shift(delta) {
        var m = month + delta;
        var y = year;
        if (m < 0) { m = 11; y--; }
        if (m > 11) { m = 0; y++; }
        month = m;
        year = y;
    }

    function cellDate(i) {
        return new Date(year, month, i - offset + 1);
    }

    Header {
        Layout.fillWidth: true
        title: cal.locale.standaloneMonthName(cal.month, Locale.LongFormat) + " " + cal.year
        subtitle: Qt.formatDate(cal.today, "dddd, d MMMM yyyy")

        Button {
            icon: "󰅁"
            flat: true
            onClicked: cal.shift(-1)
        }

        Button {
            icon: "󰋜"
            flat: true
            visible: !cal.viewingToday
            onClicked: { cal.year = cal.today.getFullYear(); cal.month = cal.today.getMonth(); }
        }

        Button {
            icon: "󰅂"
            flat: true
            onClicked: cal.shift(1)
        }
    }

    GridLayout {
        id: grid
        Layout.fillWidth: true
        columns: 7
        rowSpacing: Math.round(2 * Theme.s)
        columnSpacing: Math.round(2 * Theme.s)

        readonly property real cell: (cal.width - Theme.pad * 2 - columnSpacing * 6) / 7

        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

            Text {
                required property string modelData
                Layout.preferredWidth: grid.cell
                Layout.preferredHeight: Math.round(22 * Theme.s)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: modelData
                color: Theme.fgMuted
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                font.weight: Font.DemiBold
            }
        }

        Repeater {
            model: 42

            Rectangle {
                required property int index

                readonly property date d: cal.cellDate(index)
                readonly property bool inMonth: d.getMonth() === cal.month
                readonly property bool isToday: inMonth && cal.viewingToday && d.getDate() === cal.today.getDate()
                readonly property bool weekend: d.getDay() === 0 || d.getDay() === 6

                Layout.preferredWidth: grid.cell
                Layout.preferredHeight: Math.round(32 * Theme.s)
                radius: Theme.controlRadius
                color: isToday ? Theme.accent : (hover.hovered && inMonth ? Theme.hover : "transparent")

                HoverHandler { id: hover }

                Text {
                    anchors.centerIn: parent
                    text: parent.d.getDate()
                    color: parent.isToday ? Theme.shell
                        : !parent.inMonth ? Theme.alpha(Theme.fgMuted, 0.35)
                        : parent.weekend ? Theme.fgMuted
                        : Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.weight: parent.isToday ? Font.Bold : Font.Normal
                    font.features: { "tnum": 1 }
                }
            }
        }
    }
}
