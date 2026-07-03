pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Exposes the default audio sink's volume and mute state.
Singleton {
    id: root

    readonly property real volume: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) ? Pipewire.defaultAudioSink.audio.volume : 0
    readonly property bool muted: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) ? Pipewire.defaultAudioSink.audio.mute : false
    readonly property string sinkName: (Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.name : "—")
    readonly property string volumePercent: Math.round(volume * 100) + "%"

    // Keep the default sink tracked
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    // Cycle through volume icon levels
    readonly property string iconName: {
        if (muted) return "audio-volume-muted-symbolic"
        if (volume < 0.01) return "audio-volume-muted-symbolic"
        if (volume < 0.33) return "audio-volume-low-symbolic"
        if (volume < 0.66) return "audio-volume-medium-symbolic"
        return "audio-volume-high-symbolic"
    }
}