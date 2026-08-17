pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Drawer {
    id: control

    // No dedicated StyleReader.ControlType for Drawer, and (unlike
    // DialogButtonBox.qml/Popup.qml) its old colorSet was `window`, not
    // `view` -- falling back to plain `control` would silently change its
    // look. Reuses `pane` (widgets/containers/Pane.qml's own slot, also
    // window-colorSet background-only) instead of adding a near-identical
    // AyameStyle slot just for this file.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Pane
        enabled: control.enabled
        palette: control.palette
    }

    // Without this, the Drawer attaches to its regular QML parent instead
    // of the window's overlay layer, so it doesn't get edge-anchored
    // (Drawer.edge) or positioned above the rest of the UI correctly.
    // Matches QtQuick.Controls.Basic's own Drawer.qml.
    parent: T.Overlay.overlay

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        color: styleReader.background.color
        border.width: styleReader.background.border.width
        border.color: styleReader.background.border.color
    }
}
