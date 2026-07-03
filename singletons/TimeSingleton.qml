pragma Singleton

import Quickshell
import QtQuick

// Provides the current time as a formatted string using SystemClock.
// This avoids creating a Process + Timer per monitor.
Singleton {
    id: root

    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm AP")
    }

    readonly property string date: {
        Qt.formatDateTime(clock.date, "ddd MMM d")
    }

    readonly property string fullDateTime: {
        Qt.formatDateTime(clock.date, "ddd MMM d  hh:mm:ss AP")
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes  // no seconds needed
    }
}