pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.RangeSlider {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitWidth: control.horizontal ? Ayame.Units.gridUnit * 8 : Ayame.Units.gridUnit * 1.4
    implicitHeight: control.horizontal ? Ayame.Units.gridUnit * 1.4 : Ayame.Units.gridUnit * 8

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        width: control.horizontal ? control.availableWidth : 6
        height: control.horizontal ? 6 : control.availableHeight
        radius: 3
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: control.colors.borderColor

        Rectangle {
            x: control.horizontal ? control.first.position * parent.width : 0
            y: control.horizontal ? 0 : control.first.visualPosition * parent.height
            width: control.horizontal ? (control.second.position - control.first.position) * parent.width : parent.width
            height: control.horizontal ? parent.height : (control.second.position - control.first.position) * parent.height
            radius: 3
            color: control.colors.highlightColor
        }
    }

    first.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.first.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.first.visualPosition * (control.availableHeight - height))
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: control.first.pressed ? control.colors.pressedColor : (control.first.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: Ayame.Units.borderWidth
        border.color: control.colors.highlightColor
    }

    second.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.second.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.second.visualPosition * (control.availableHeight - height))
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: control.second.pressed ? control.colors.pressedColor : (control.second.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: Ayame.Units.borderWidth
        border.color: control.colors.highlightColor
    }
}
