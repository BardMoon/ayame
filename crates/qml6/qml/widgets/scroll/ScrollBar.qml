pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.ScrollBar {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

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
        color: (control.pressed || control.hovered) ? control.colors.highlightColor : control.colors.subColor
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
