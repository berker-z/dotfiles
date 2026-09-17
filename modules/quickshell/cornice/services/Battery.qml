pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Laptop battery via UPower. `present` is false on the desktop, so the bar
// item simply does not exist there. `mock(pct, state)` fakes a battery for
// looking at the widget on a machine without one.
Singleton {
    id: battery

    property int mockPercent: -1
    property string mockState: ""

    readonly property var device: UPower.displayDevice
    readonly property bool real: device !== null && device.ready && device.isLaptopBattery && device.isPresent
    readonly property bool mocked: mockPercent >= 0
    readonly property bool present: mocked || real

    readonly property int percent: mocked ? mockPercent : (real ? Math.round(device.percentage) : 0)
    readonly property bool charging: mocked
        ? (mockState === "charging" || mockState === "full")
        : (real && (device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge))
    readonly property bool full: mocked
        ? mockState === "full"
        : (real && device.state === UPowerDeviceState.FullyCharged)
    readonly property bool plugged: charging || full || (mocked ? false : (real && !UPower.onBattery))

    // Same thresholds waybar had: warning at 30, critical at 15.
    readonly property bool warning: !plugged && percent <= 30 && percent > 15
    readonly property bool critical: !plugged && percent <= 15

    // Seconds; 0 when unknown.
    readonly property int secondsLeft: mocked
        ? (mockState === "charging" ? 2700 : mockState === "full" ? 0 : 9840)
        : (real ? Math.round(charging ? device.timeToFull : device.timeToEmpty) : 0)

    readonly property string timeText: {
        if (full)
            return "Full";
        if (secondsLeft <= 0)
            return charging ? "Charging" : "—";
        var h = Math.floor(secondsLeft / 3600);
        var m = Math.floor((secondsLeft % 3600) / 60);
        return (h > 0 ? h + "h " : "") + m + "m" + (charging ? " to full" : " left");
    }

    readonly property string icon: {
        if (full)
            return "󰁹";
        if (charging)
            return percent < 20 ? "󰢜" : percent < 40 ? "󰂆" : percent < 60 ? "󰂈" : percent < 80 ? "󰂉" : "󰂋";
        return percent < 10 ? "󰂎" : percent < 20 ? "󰁺" : percent < 30 ? "󰁻" : percent < 40 ? "󰁼"
            : percent < 50 ? "󰁽" : percent < 60 ? "󰁾" : percent < 70 ? "󰁿" : percent < 80 ? "󰂀"
            : percent < 90 ? "󰂁" : percent < 100 ? "󰂂" : "󰁹";
    }

    function mock(pct, state) {
        var n = Number(pct);
        if (!isFinite(n) || n < 0) {
            mockPercent = -1;
            mockState = "";
            return;
        }
        mockPercent = Math.max(0, Math.min(100, Math.round(n)));
        mockState = state || "discharging";
    }
}
