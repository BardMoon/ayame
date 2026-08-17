pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.Frame {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    padding: StyleKit.Units.smallSpacing

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        radius: StyleKit.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: StyleKit.Units.borderWidth
        border.color: control.colors.borderColor
    }
}
