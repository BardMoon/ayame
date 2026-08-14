pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Ayame 1.0 as Ayame

T.RangeSlider {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitWidth: Ayame.Units.gridUnit * 8
    implicitHeight: Ayame.Units.gridUnit * 1.4

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: control.availableWidth
        height: 6
        radius: 3
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)

        Rectangle {
            x: control.first.visualPosition * parent.width
            width: (control.second.visualPosition - control.first.visualPosition) * parent.width
            height: parent.height
            radius: 3
            color: control.colors.highlightColor
        }
    }

    first.handle: Rectangle {
        x: control.leftPadding + control.first.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight - height) / 2
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: control.first.pressed ? control.colors.highlightColor : (control.first.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: Ayame.Units.borderWidth
        border.color: control.colors.highlightColor
    }

    second.handle: Rectangle {
        x: control.leftPadding + control.second.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight - height) / 2
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: control.second.pressed ? control.colors.highlightColor : (control.second.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: Ayame.Units.borderWidth
        border.color: control.colors.highlightColor
    }
}
