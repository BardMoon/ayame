pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.MenuSeparator {
    id: control

    property int colorSet: StyleKit.Theme.header
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    padding: StyleKit.Units.smallSpacing

    implicitWidth: Math.max(implicitBackgroundWidth + leftPadding + rightPadding, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topPadding + bottomPadding, implicitContentHeight + topPadding + bottomPadding)

    contentItem: Rectangle {
        implicitWidth: 100
        implicitHeight: 1
        color: control.colors.subColor
    }
}
