pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.ToolTip {
    id: control

    // Neither a StyleReader.ControlType nor an AbstractStylableControls
    // slot exists for ToolTip (the Phase 0 open question this task file
    // flagged, now resolved: still missing even after everything else in
    // this migration landed) -- the old `tooltip` colorSet
    // (`palette.light`/`.windowText`, unlike any other colorSet) is
    // computed locally instead, off the live palette. Only
    // `background.border.width` still comes through a StyleReader (falls
    // back to `control`, same value either way) -- see Menu.qml's
    // identical approach.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        palette: control.palette
    }

    readonly property color _tooltipBackground: control.palette.light
    readonly property color _tooltipText: control.palette.windowText
    readonly property color _tooltipBorder: Qt.rgba(control._tooltipText.r, control._tooltipText.g, control._tooltipText.b, 0.3)

    // T.Popup's default position is (0, 0) relative to its parent -- for
    // a ToolTip that parent is the hovered item itself, so without this
    // the tooltip renders directly on top of/covering whatever it's
    // describing instead of next to it. Same offset-above-and-centered
    // positioning as both QtQuick.Controls.Basic's and
    // qqc2-breeze-style's own ToolTip.qml.
    x: control.parent ? (control.parent.width - implicitWidth) / 2 : 0
    y: -implicitHeight - StyleKit.Units.smallSpacing
    z: 999

    padding: StyleKit.Units.smallSpacing

    // Without this, T.ToolTip falls back to its base Popup closePolicy
    // (CloseOnEscape only), so a tooltip left open by e.g. a long hover
    // won't dismiss on an outside click/tap. Matches
    // QtQuick.Controls.Basic's own ToolTip.qml.
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        radius: styleReader.background.radius
        color: control._tooltipBackground
        border.width: styleReader.background.border.width
        border.color: control._tooltipBorder
    }

    contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control._tooltipText
    }
}
