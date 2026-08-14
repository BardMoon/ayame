pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.ComboBox {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    spacing: Ayame.Units.smallSpacing
    padding: Ayame.Units.smallSpacing
    implicitHeight: Ayame.Units.gridUnit * 1.6
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)

    // Reserve room for `indicator` by shrinking the control's own
    // available content area -- setting padding on contentItem's own Text
    // only moves where it *elides*, not the box Control actually lays it
    // out into (Control always resizes contentItem to availableWidth
    // regardless), so the indicator arrow used to render on top of the
    // display text instead of next to it. Same root-level-padding
    // approach as QtQuick.Controls.Basic's own ComboBox.qml.
    leftPadding: padding + (control.mirrored && control.indicator ? control.indicator.width + control.spacing : 0)
    rightPadding: padding + (!control.mirrored && control.indicator ? control.indicator.width + control.spacing : 0)

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: Ayame.Units.borderWidth
        border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        text: control.displayText
        font: control.font
        color: control.colors.textColor
        elide: Text.ElideRight
    }

    indicator: Text {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        text: "▾"
        font: control.font
        color: control.colors.textColor
    }
}
