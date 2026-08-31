pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Container {
    id: control

    // No dedicated StyleReader.ControlType for the generic Container base
    // type -- falls back to AyameStyle's `control` slot. Passthrough-only,
    // same rationale as AbstractButton.qml/Control.qml's own `colors`.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        palette: control.palette
    }

    readonly property var colors: ({
        backgroundColor: styleReader.background.color,
        borderColor: styleReader.background.border.color,
        textColor: styleReader.text.color,
        highlightColor: control.palette.highlight,
        highlightedTextColor: control.palette.highlightedText
    })

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)
}
