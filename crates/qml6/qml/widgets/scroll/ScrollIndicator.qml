pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.ScrollIndicator {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    padding: 2

    implicitWidth: Math.max(implicitBackgroundWidth + leftPadding + rightPadding, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topPadding + bottomPadding, implicitContentHeight + topPadding + bottomPadding)

    contentItem: Rectangle {
        implicitWidth: 4
        implicitHeight: 4
        radius: 2
        color: control.colors.highlightColor
        opacity: control.active ? 0.6 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }
}
