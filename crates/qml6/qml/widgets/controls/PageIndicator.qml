pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.PageIndicator {
    id: control

    // Inactive dots want a translucent text color ("subColor" in the old
    // StyleKit.Theme) with no Qt.labs.StyleKit ControlStyle equivalent
    // (no dedicated PageIndicator slot, and no "sub"/dimmed color concept
    // in ControlStyle at all) -- kept as a local blend off the live
    // palette instead, same formula the old Theme.paletteFor() used.
    readonly property color _subColor: Qt.rgba(control.palette.text.r, control.palette.text.g, control.palette.text.b, 0.3)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    padding: StyleKit.Units.smallSpacing
    spacing: StyleKit.Units.smallSpacing

    delegate: Rectangle {
        required property int index

        implicitWidth: 8
        implicitHeight: 8
        radius: 4
        color: index === control.currentIndex ? control.palette.highlight : control._subColor
    }

    // T.PageIndicator has no built-in layout for its delegates -- without
    // this, `delegate` is never actually instantiated `count` times
    // anywhere. Same Row+Repeater-over-count idiom as
    // QtQuick.Controls.Basic's own PageIndicator.qml.
    contentItem: Row {
        spacing: control.spacing

        Repeater {
            model: control.count
            delegate: control.delegate
        }
    }
}
