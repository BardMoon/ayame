pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.RangeSlider {
    id: control

    // No dedicated StyleReader.ControlType for RangeSlider -- falls back
    // to the generic `control` slot, same as Dial/PageIndicator/Tumbler.
    // Track itself isn't interactive (rest state only); each handle gets
    // its own StyleReader below bound to that handle's own hovered/pressed
    // (T.RangeSlider's two handles have independent state, unlike
    // Slider.qml's single handle).
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        palette: control.palette
    }

    LabsStyleKit.StyleReader {
        id: firstHandleStyleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        hovered: control.first.hovered
        pressed: control.first.pressed
        palette: control.palette
    }

    LabsStyleKit.StyleReader {
        id: secondHandleStyleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        hovered: control.second.hovered
        pressed: control.second.pressed
        palette: control.palette
    }

    hoverEnabled: true
    implicitWidth: control.horizontal ? StyleKit.Units.gridUnit * 8 : StyleKit.Units.gridUnit * 1.4
    implicitHeight: control.horizontal ? StyleKit.Units.gridUnit * 1.4 : StyleKit.Units.gridUnit * 8

    background: Ayame.TrackBar {
        id: track
        x: control.leftPadding + (control.horizontal ? 0 : Math.round((control.availableWidth - width) / 2))
        y: control.topPadding + (control.horizontal ? Math.round((control.availableHeight - height) / 2) : 0)
        width: control.horizontal ? control.availableWidth : track.thickness
        height: control.horizontal ? track.thickness : control.availableHeight
        trackColor: styleReader.background.color
        trackBorderColor: styleReader.background.border.color

        Rectangle {
            x: control.horizontal ? control.first.position * parent.width : 0
            y: control.horizontal ? 0 : control.first.visualPosition * parent.height
            width: control.horizontal ? (control.second.position - control.first.position) * parent.width : parent.width
            height: control.horizontal ? parent.height : (control.second.position - control.first.position) * parent.height
            radius: parent.radius
            color: control.palette.highlight
        }
    }

    // Handle border stays a direct opaque highlight (not
    // styleReader.background.border.color) regardless of state --
    // matches Slider.qml's handle, same "translucent tint reads as
    // see-through on a small filled shape" rationale.
    first.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.first.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.first.visualPosition * (control.availableHeight - height))
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: firstHandleStyleReader.background.color
        border.width: firstHandleStyleReader.background.border.width
        border.color: control.palette.highlight
    }

    second.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.second.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.second.visualPosition * (control.availableHeight - height))
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: secondHandleStyleReader.background.color
        border.width: secondHandleStyleReader.background.border.width
        border.color: control.palette.highlight
    }
}
