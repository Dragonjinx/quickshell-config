pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

// Exposes battery status from UPower.
Singleton {
    id: root

    readonly property UPowerDevice battery: UPower.battery
    readonly property real percentage: battery ? battery.percentage : -1
    readonly property bool charging: battery ? battery.state === UPowerDeviceState.Charging : false
    readonly property bool pluggedIn: battery ? battery.state === UPowerDeviceState.FullyCharged : false
    readonly property string displayText: {
        if (percentage < 0) return "\u2014"
        return Math.round(percentage) + "%"
    }

    readonly property string iconName: {
        if (percentage < 0) return "battery-missing-symbolic"
        if (pluggedIn) return "battery-full-charged-symbolic"
        if (charging) return "battery-good-charging-symbolic"
        if (percentage < 10) return "battery-caution-symbolic"
        if (percentage < 30) return "battery-low-symbolic"
        if (percentage < 60) return "battery-good-symbolic"
        return "battery-full-symbolic"
    }

    property int refreshTimer: 0

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            root.refreshTimer = root.refreshTimer + 1
        }
    }
}