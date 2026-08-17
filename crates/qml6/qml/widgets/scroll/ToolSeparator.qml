pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.ToolSeparator {
    id: control

    // See AyameStyle.qml's own `toolSeparator` slot comment for why
    // `background.color` (not `.border.color`) is the property read here.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.ToolSeparator
        enabled: control.enabled
        palette: control.palette
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftPadding + rightPadding, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topPadding + bottomPadding, implicitContentHeight + topPadding + bottomPadding)

    contentItem: Rectangle {
        implicitWidth: control.vertical ? 1 : 8
        implicitHeight: control.vertical ? 8 : 1
        color: styleReader.background.color
    }
}
