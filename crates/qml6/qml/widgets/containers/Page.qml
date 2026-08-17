pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.Page {
    id: control

    property int colorSet: StyleKit.Theme.window
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding, implicitHeaderWidth, implicitFooterWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding + (implicitHeaderHeight > 0 ? implicitHeaderHeight : 0) + (implicitFooterHeight > 0 ? implicitFooterHeight : 0))

    background: Rectangle {
        color: control.colors.backgroundColor
    }
}
