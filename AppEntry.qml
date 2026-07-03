import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

// Individual entry in the application launcher list.
Rectangle {
    id: root

    required property DesktopEntry entry

    height: 44
    radius: 8
    color: ma.containsMouse ? Theme.launcherSelected : "transparent"

    Behavior on color { ColorAnimation { duration: 80 } }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
        }
        spacing: 12

        IconImage {
            implicitSize: 28
            source: entry.icon ? Quickshell.iconPath(entry.icon) : ""
            visible: entry.icon !== ""
        }

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: entry.name
                font.pixelSize: Theme.launchFontSize
                font.bold: true
                color: Theme.launchText
                elide: Text.ElideRight
            }

            Text {
                text: entry.genericName || ""
                font.pixelSize: Theme.launchFontSize - 2
                color: Theme.launchDim
                elide: Text.ElideRight
                visible: entry.genericName !== ""
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            entry.execute()
            AppLauncher.close()
        }
    }
}