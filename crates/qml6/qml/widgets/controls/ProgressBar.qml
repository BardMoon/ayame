pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Ayame 1.0 as Ayame

T.ProgressBar {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    implicitWidth: Ayame.Units.gridUnit * 8
    implicitHeight: 6

    background: Rectangle {
        implicitWidth: Ayame.Units.gridUnit * 8
        implicitHeight: 6
        radius: 3
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    contentItem: Item {
        implicitWidth: Ayame.Units.gridUnit * 8
        implicitHeight: 6

        Rectangle {
            width: control.position * parent.width
            height: parent.height
            radius: 3
            color: control.colors.highlightColor
        }
    }
}
