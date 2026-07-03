import QtQuick
import Quickshell

// Volume widget — click to toggle mute, shows Nerd Font icon + percentage.
Item {
    id: root
    implicitWidth: 60

    readonly property string iconNerd: VolumeSingleton.muted ? "\uf466" :         // nf-fa-volume_off
                                        VolumeSingleton.volume < 0.01 ? "\uf026" :  // nf-fa-volume_off (same)
                                        VolumeSingleton.volume < 0.33 ? "\uf027" :  // nf-fa-volume_down
                                                                       "\uf028"     // nf-fa-volume_up

    Row {
        anchors.centerIn: parent
        spacing: 6
        opacity: VolumeSingleton.muted ? 0.5 : 1.0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: root.iconNerd
            color: VolumeSingleton.muted ? Theme.error : Theme.barText
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: VolumeSingleton.volumePercent
            font.pixelSize: Theme.barFontSize
            color: VolumeSingleton.muted ? Theme.error : Theme.barText
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        }
    }
}