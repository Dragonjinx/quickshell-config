import QtQuick
import Quickshell
import Quickshell.Widgets

// Volume widget — click to toggle mute, shows icon + percentage.
Item {
    id: root

    implicitWidth: volumeRow.implicitWidth + 12
    height: parent?.implicitHeight ?? 30

    Row {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 6

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 14
            source: Quickshell.iconPath(VolumeSingleton.iconName)
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
            // Toggle mute via wpctl
            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        }
    }
}