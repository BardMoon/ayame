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

    contentItem: Rectangle {
        implicitWidth: control.interactive ? 8 : 4
        implicitHeight: control.interactive ? 8 : 4
        radius: width / 2
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.4))
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
