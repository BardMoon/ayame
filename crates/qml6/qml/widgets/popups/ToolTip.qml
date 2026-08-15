pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.ToolTip {
    id: control

    property int colorSet: Ayame.Theme.tooltip
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    // T.Popup's default position is (0, 0) relative to its parent -- for
    // a ToolTip that parent is the hovered item itself, so without this
    // the tooltip renders directly on top of/covering whatever it's
    // describing instead of next to it. Same offset-above-and-centered
    // positioning as both QtQuick.Controls.Basic's and
    // qqc2-breeze-style's own ToolTip.qml.
    x: control.parent ? (control.parent.width - implicitWidth) / 2 : 0
    y: -implicitHeight - Ayame.Units.smallSpacing
    z: 999

    padding: Ayame.Units.smallSpacing

    // Without this, T.ToolTip falls back to its base Popup closePolicy
    // (CloseOnEscape only), so a tooltip left open by e.g. a long hover
    // won't dismiss on an outside click/tap. Matches
    // QtQuick.Controls.Basic's own ToolTip.qml.
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.colors.textColor
    }
}
