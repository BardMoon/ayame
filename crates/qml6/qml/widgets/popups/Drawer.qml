pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.Drawer {
    id: control

    property int colorSet: StyleKit.Theme.window
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    // Without this, the Drawer attaches to its regular QML parent instead
    // of the window's overlay layer, so it doesn't get edge-anchored
    // (Drawer.edge) or positioned above the rest of the UI correctly.
    // Matches QtQuick.Controls.Basic's own Drawer.qml.
    parent: T.Overlay.overlay

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        color: control.colors.backgroundColor
        border.width: StyleKit.Units.borderWidth
        border.color: control.colors.borderColor
    }
}
