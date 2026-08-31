pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.ScrollBar {
    id: control

    // No StyleReader here at all -- unlike every other file in this
    // directory batch, this one's `subColor` rest-state color has no
    // Qt.labs.StyleKit equivalent (same as PageIndicator's dots) and
    // `highlightColor` is a direct palette pass-through, so nothing ends
    // up read through `scrollBar` (the dedicated slot for this, but its
    // old look was identical to `control`'s view colorSet anyway).
    readonly property color _subColor: Qt.rgba(control.palette.text.r, control.palette.text.g, control.palette.text.b, 0.3)

    implicitWidth: Math.max(implicitBackgroundWidth + leftPadding + rightPadding, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topPadding + bottomPadding, implicitContentHeight + topPadding + bottomPadding)

    padding: 2

    visible: control.policy !== T.ScrollBar.AlwaysOff
    // Keeps the handle from shrinking to an unusably thin/unclickable
    // sliver on a very short or very narrow ScrollBar. Same formula as
    // QtQuick.Controls.Basic's own ScrollBar.qml.
    minimumSize: control.orientation === Qt.Horizontal ? height / width : width / height

    contentItem: Rectangle {
        implicitWidth: control.interactive ? 8 : 4
        implicitHeight: control.interactive ? 8 : 4
        radius: width / 2
        color: (control.pressed || control.hovered) ? control.palette.highlight : control._subColor
        opacity: control.active ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    background: Rectangle {
        implicitWidth: control.interactive ? 8 : 4
        implicitHeight: control.interactive ? 8 : 4
        color: "transparent"
    }
}
