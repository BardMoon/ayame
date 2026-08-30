pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.MenuSeparator {
    id: control

    // No AbstractStylableControls slot for MenuSeparator either (see
    // Menu.qml's own comment) -- but its rule color is the exact same
    // "header colorSet's blend(text, 0.3)" formula as
    // scroll/ToolSeparator.qml's own rule, so it just reuses that
    // widget's `toolSeparator` slot directly rather than duplicating the
    // math locally.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.ToolSeparator
        enabled: control.enabled
        palette: control.palette
    }

    padding: StyleKit.Units.smallSpacing

    implicitWidth: Math.max(implicitBackgroundWidth + leftPadding + rightPadding, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topPadding + bottomPadding, implicitContentHeight + topPadding + bottomPadding)

    contentItem: Rectangle {
        implicitWidth: 100
        implicitHeight: 1
        color: styleReader.background.color
    }
}
