pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

// Battery state sourced from the UPower system service.
//
// Sources everything from `UPower.displayDevice` — UPower's aggregated
// primary battery. No sysfs parsing, no `udevadm monitor`, no polling:
// every field below is a bindable property on the UPowerDevice and updates
// via its change signals (plug/unplug, charge level, power draw).
//
// Semantics:
//   - percentage       : 0..100 int, -1 when no battery
//   - powerWatts       : SIGNED watts — positive while charging, negative
//                        while discharging (UPower's changeRate)
//   - state            : UPowerDeviceState enum
Singleton {
    id: root

    // The aggregated system battery (UPower's DisplayDevice). Never null,
    // but may not be initialized yet — guard with `ready`.
    readonly property var device: UPower.displayDevice
    readonly property bool ready: device ? device.ready : false

    // Whether a real laptop battery is present and initialized.
    readonly property bool present: ready && device.isLaptopBattery

    // Charge level 0..100, or -1 when unavailable.
    readonly property int percentage: present
        ? Math.round(Math.max(0, Math.min(100, device.percentage * 100)))
        : -1

    // Current charge state (UPowerDeviceState enum).
    readonly property var state: present ? device.state : UPowerDeviceState.Unknown

    readonly property bool charging: state === UPowerDeviceState.Charging
    readonly property bool discharging: state === UPowerDeviceState.Discharging
    readonly property bool fullyCharged: state === UPowerDeviceState.FullyCharged
    readonly property bool onBattery: discharging
    readonly property bool pluggedIn:
        charging || fullyCharged || state === UPowerDeviceState.PendingCharge

    // Signed power in watts: positive = charging, negative = discharging.
    // (UPower changeRate is negative while draining.)
    readonly property real powerWatts: present ? (device.changeRate || 0) : 0

    // Whether there's a meaningful power reading right now.
    readonly property bool powerAvailable: present && (charging || discharging) && Math.abs(powerWatts) > 0

    // Estimated seconds remaining, or -1 when unknown / not relevant.
    readonly property int secondsRemaining: {
        if (!present) return -1
        if (charging) return device.timeToFull
        if (discharging) return device.timeToEmpty
        return 0
    }

    readonly property string displayText: percentage < 0 ? "\u2014" : percentage + "%"

    // Formatted as "Xh Ym" (↑ when charging).
    readonly property string timeRemainingText: {
        if (secondsRemaining <= 0) return "\u2014"
        var h = Math.floor(secondsRemaining / 3600)
        var m = Math.round((secondsRemaining % 3600) / 60)
        if (charging) return h + "h " + m + "m \u2191"
        return h + "h " + m + "m"
    }

    // Nerd Font icon based on state
    readonly property string iconNerd: {
        if (percentage < 0) return ""
        if (pluggedIn) return "\uf1e6"         // nf-fa-plug
        if (charging) return "\uf0e7"          // nf-fa-bolt
        if (percentage < 15) return "\uf244"   // nf-fa-battery_0
        if (percentage < 40) return "\uf243"   // nf-fa-battery_1
        if (percentage < 65) return "\uf242"   // nf-fa-battery_2
        if (percentage < 90) return "\uf241"   // nf-fa-battery_3
        return "\uf240"                          // nf-fa-battery_4
    }
}
