pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import Qt.labs.StyleKit as LabsStyleKit

T.AbstractButton {
    id: control

    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.AbstractButton
        enabled: control.enabled
        focused: control.activeFocus
        checked: control.checked
        hovered: control.hovered
        pressed: control.pressed
        palette: control.palette
    }

    // Public passthrough for callers supplying their own background/
    // contentItem against a bare Ayame.AbstractButton -- nothing in this
    // file itself paints with these (no built-in Ayame control extends
    // this delegate).
    readonly property var colors: ({
        backgroundColor: styleReader.background.color,
        borderColor: styleReader.background.border.color,
        textColor: styleReader.text.color,
        highlightColor: control.palette.highlight,
        highlightedTextColor: control.palette.highlightedText
    })

    hoverEnabled: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)
}
