pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Exposes the default audio sink's volume & mute state,
// plus the default audio source (mic) mute state.
Singleton {
    id: root

    // --- Sink (speakers/headphones) ---
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property string volumePercent: Math.round(volume * 100) + "%"

    // --- Source (mic) ---
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool micMuted: source && source.audio ? source.audio.muted : false

    // Track the sink and source nodes so their .audio properties are valid
    PwObjectTracker {
        id: sinkTracker
        objects: [ Pipewire.defaultAudioSink ]
    }

    PwObjectTracker {
        id: sourceTracker
        objects: [ Pipewire.defaultAudioSource ]
    }

    // Rebind trackers when the default sink/source changes
    property var prevSink: null
    property var prevSource: null

    onSinkChanged: {
        if (sink !== prevSink) {
            sinkTracker.objects = [ sink ]
            prevSink = sink
        }
    }

    onSourceChanged: {
        if (source !== prevSource) {
            sourceTracker.objects = [ source ]
            prevSource = source
        }
    }

    // Icon helpers
    readonly property string sinkIcon: {
        if (muted) return "󰖁"   // md-volume_off
        if (volume < 0.01) return "󰖁" // md-volume_off (same icon)
        if (volume < 0.33) return "󰕿" // md-volume_low
        return "󰕾"               // md-volume_high
    }

    readonly property string micIcon: {
        if (source && source.audio && source.audio.muted) return "󰍭" // md-microphone_off
        return "󰍬"               // md-microphone
    }

    // Sync mute LEDs directly from PipeWire state (same source as the icon bindings)
    onMicMutedChanged: {
        Quickshell.execDetached(["brightnessctl", "-d", "platform::micmute", "set", micMuted ? "1" : "0"])
    }

    onMutedChanged: {
        Quickshell.execDetached(["brightnessctl", "-d", "platform::mute", "set", muted ? "1" : "0"])
    }

    Component.onCompleted: {
        // Sync initial state
        Quickshell.execDetached(["brightnessctl", "-d", "platform::micmute", "set", micMuted ? "1" : "0"])
        Quickshell.execDetached(["brightnessctl", "-d", "platform::mute", "set", muted ? "1" : "0"])
    }
}