pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Control {
    id: control

    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        focused: control.activeFocus
        palette: control.palette
    }

    // Passthrough-only delegate, same rationale as AbstractButton.qml's
    // own `colors` property -- nothing in this file paints with it.
    readonly property var colors: ({
        backgroundColor: styleReader.background.color,
        borderColor: styleReader.background.border.color,
        textColor: styleReader.text.color,
        highlightColor: control.palette.highlight,
        highlightedTextColor: control.palette.highlightedText
    })

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)
}
