import QtQuick
import Quickshell
import Quickshell.Widgets

// Individual entry in the application launcher list.
Rectangle {
    id: root

    required property DesktopEntry entry
    property var launchAppCallback: null
    property bool selected: false
    signal activated()

    height: 44
    radius: Theme.rounding.sm
    color: ma.containsMouse || root.selected ? Theme.launchSel : "transparent"


    Text {
        anchors {
            left: parent.left
            leftMargin: Theme.padding.md
            right: parent.right
            rightMargin: Theme.padding.md
            verticalCenter: parent.verticalCenter
        }
        text: entry.name
        font.pixelSize: Theme.launchFontSize
        color: ma.containsMouse || root.selected ? Theme.launchTextSel : Theme.launchText
        elide: Text.ElideRight
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.launchAppCallback) root.launchAppCallback(root.entry)
            else root.entry.execute()
            root.activated()
        }
    }
}
