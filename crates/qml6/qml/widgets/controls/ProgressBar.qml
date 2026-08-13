pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Ayame 1.0

QQC2.ProgressBar {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

    implicitWidth: Units.gridUnit * 8
    implicitHeight: 6

    background: Rectangle {
        implicitWidth: Units.gridUnit * 8
        implicitHeight: 6
        radius: 3
        color: control.colors.backgroundColor
        border.width: Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    contentItem: Item {
        implicitWidth: Units.gridUnit * 8
        implicitHeight: 6

        Rectangle {
            width: control.position * parent.width
            height: parent.height
            radius: 3
            color: control.colors.highlightColor
        }
    }
}
