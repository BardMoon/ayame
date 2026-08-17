pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.SpinBox {
    id: control

    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.SpinBox
        enabled: control.enabled
        focused: control.activeFocus
        palette: control.palette
    }

    // up/down are "ghost" buttons (transparent at rest, tinted on
    // hover/press, no border) -- the exact same shape as ToolButton, so
    // reused directly instead of inventing a separate SpinBox-indicator
    // slot in AyameStyle.
    LabsStyleKit.StyleReader {
        id: upStyleReader
        controlType: LabsStyleKit.StyleReader.ToolButton
        enabled: control.enabled
        hovered: control.up.hovered
        pressed: control.up.pressed
        palette: control.palette
    }

    LabsStyleKit.StyleReader {
        id: downStyleReader
        controlType: LabsStyleKit.StyleReader.ToolButton
        enabled: control.enabled
        hovered: control.down.hovered
        pressed: control.down.pressed
        palette: control.palette
    }

    hoverEnabled: true
    padding: StyleKit.Units.smallSpacing
    implicitHeight: StyleKit.Units.gridUnit * 1.6
    // The indicator column's width is reserved via leftPadding/rightPadding
    // below (not added again here), same as QtQuick.Controls.Basic's own
    // SpinBox.qml -- otherwise it'd be double-counted.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)

    // Without this, contentItem (an interactive TextInput) spans the full
    // control width and overlaps up.indicator/down.indicator, which are
    // positioned at the left/right edges independently -- so it eats the
    // press events meant for the +/- buttons and increase()/decrease()
    // never fire. Same fix QtQuick.Controls.Basic's own SpinBox.qml
    // applies ("the width of the indicators are calculated into the
    // padding").
    leftPadding: padding + (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0))
    rightPadding: padding + (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0))

    // contentItem below reads control.validator; without a validator here
    // it stays null, so typing in an editable SpinBox never gets
    // constrained to the from/to range. Matches QtQuick.Controls.Basic's
    // own SpinBox.qml.
    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: styleReader.background.radius
            color: styleReader.background.color
            border.width: styleReader.background.border.width
            border.color: styleReader.background.border.color
        }

        // Same activeFocus cue as widgets/Button.qml -- see
        // HighlightRing.qml -- SpinBox has no `highlighted` state so
        // only the fade+pulse `active` ring applies here.
        Ayame.HighlightRing {
            anchors.fill: parent
            active: control.activeFocus
            ringColor: control.palette.highlight
        }
    }

    contentItem: TextInput {
        text: control.displayText
        font: control.font
        color: styleReader.text.color
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        implicitWidth: StyleKit.Units.gridUnit * 1.2
        radius: upStyleReader.background.radius
        color: upStyleReader.background.color

        Text {
            text: "+"
            anchors.centerIn: parent
            color: upStyleReader.text.color
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: StyleKit.Units.gridUnit * 1.2
        radius: downStyleReader.background.radius
        color: downStyleReader.background.color

        Text {
            text: "-"
            anchors.centerIn: parent
            color: downStyleReader.text.color
        }
    }
}
