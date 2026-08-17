pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Frame {
    id: control

    // `frame` has a dedicated AbstractStylableControls slot, but its old
    // look was identical to `control`'s (view colorSet) -- no AyameStyle
    // override needed, just cascades.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Frame
        enabled: control.enabled
        palette: control.palette
    }

    padding: StyleKit.Units.smallSpacing

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        radius: styleReader.background.radius
        color: styleReader.background.color
        border.width: styleReader.background.border.width
        border.color: styleReader.background.border.color
    }
}
