import QtQuick
import Quickshell
import Quickshell.Widgets

// Volume widget — click to toggle mute, shows icon + percentage.
Item {
    id: root

    implicitWidth: 60
    height: parent ? parent.implicitHeight : 30

    Row {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 6
        opacity: VolumeSingleton.muted ? 0.5 : 1.0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: VolumeSingleton.muted ? "🔇" : "🔊"
            font.pixelSize: 11
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