pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.RangeSlider {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitWidth: control.horizontal ? StyleKit.Units.gridUnit * 8 : StyleKit.Units.gridUnit * 1.4
    implicitHeight: control.horizontal ? StyleKit.Units.gridUnit * 1.4 : StyleKit.Units.gridUnit * 8

    background: Ayame.TrackBar {
        id: track
        x: control.leftPadding + (control.horizontal ? 0 : Math.round((control.availableWidth - width) / 2))
        y: control.topPadding + (control.horizontal ? Math.round((control.availableHeight - height) / 2) : 0)
        width: control.horizontal ? control.availableWidth : track.thickness
        height: control.horizontal ? track.thickness : control.availableHeight
        trackColor: control.colors.backgroundColor
        trackBorderColor: control.colors.borderColor

        Rectangle {
            x: control.horizontal ? control.first.position * parent.width : 0
            y: control.horizontal ? 0 : control.first.visualPosition * parent.height
            width: control.horizontal ? (control.second.position - control.first.position) * parent.width : parent.width
            height: control.horizontal ? parent.height : (control.second.position - control.first.position) * parent.height
            radius: parent.radius
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
        border.width: StyleKit.Units.borderWidth
        border.color: control.colors.highlightColor
    }

    second.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.second.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.second.visualPosition * (control.availableHeight - height))
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: control.second.pressed ? control.colors.pressedColor : (control.second.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: StyleKit.Units.borderWidth
        border.color: control.colors.highlightColor
    }
}
