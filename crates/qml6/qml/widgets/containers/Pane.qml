pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.Pane {
    id: control

    property int colorSet: StyleKit.Theme.window
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        color: control.colors.backgroundColor
    }
}
