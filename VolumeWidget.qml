import QtQuick
import Quickshell

// Volume widget — click to toggle mute, shows Nerd Font icon + percentage.
// Left-click toggles sink (speaker) mute. Right-click toggles source (mic) mute.
Item {
    id: root
    implicitWidth: contentRow.implicitWidth + 12

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6
        opacity: VolumeSingleton.muted || VolumeSingleton.micMuted ? 0.75 : 1.0

        // Speaker icon
        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: VolumeSingleton.sinkIcon
            color: VolumeSingleton.muted ? Theme.error : Theme.barText
        }

        // Volume percentage (hidden when muted)
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: VolumeSingleton.volumePercent
            font.pixelSize: Theme.barFontSize
            color: Theme.barText
            visible: !VolumeSingleton.muted
        }

        // Mic icon
        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFam
            text: VolumeSingleton.micIcon
            color: VolumeSingleton.micMuted ? Theme.error : Theme.barText
            font.pixelSize: Theme.barFontSize - 1
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                Quickshell.execDetached(["pavucontrol"])
            } else {
                Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
            }
        }
    }
}