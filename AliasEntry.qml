import QtQuick
import QtQuick.Layouts

// Individual entry in the launcher's alias mode (":" prefix).
// Mirrors AppEntry styling; shows name + definition on one row.
Rectangle {
    id: root

    required property string aliasName
    required property string definition
    property var launchCallback: null
    property bool selected: false
    signal activated()

    height: 44
    radius: Theme.rounding.sm
    color: ma.containsMouse || root.selected ? Theme.launchSel : "transparent"

    RowLayout {
        anchors {
            left: parent.left
            leftMargin: Theme.padding.md
            right: parent.right
            rightMargin: Theme.padding.md
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.padding.sm

        Text {
            text: root.aliasName
            font.pixelSize: Theme.launchFontSize
            font.bold: true
            color: ma.containsMouse || root.selected ? Theme.launchTextSel : Theme.launchText
            elide: Text.ElideRight
        }

        Text {
            text: "·"
            font.pixelSize: 12
            font.bold: true
            color: Theme.launchDim
            visible: root.definition.length > 0
        }

        Text {
            Layout.fillWidth: true
            text: root.definition
            font.pixelSize: 12
            color: ma.containsMouse || root.selected ? Theme.launchTextSel : Theme.launchDim
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.launchCallback) root.launchCallback(root.aliasName)
            root.activated()
        }
    }
}