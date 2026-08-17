pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.GroupBox {
    id: control

    // `groupBox` has a dedicated slot, but its old look was identical to
    // `control`'s (view colorSet) -- no AyameStyle override needed.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.GroupBox
        enabled: control.enabled
        palette: control.palette
    }

    padding: StyleKit.Units.largeSpacing

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding, implicitLabelWidth)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    label: Ayame.Label {
        x: control.leftPadding
        width: control.availableWidth
        text: control.title
        font: Qt.font({ family: control.font.family, pointSize: control.font.pointSize, bold: true })
        color: styleReader.text.color
        elide: Text.ElideRight
    }

    background: Rectangle {
        y: control.topPadding - control.bottomPadding
        width: parent.width
        height: parent.height - control.topPadding + control.bottomPadding
        radius: StyleKit.Units.cornerRadius
        color: "transparent"
        border.width: styleReader.background.border.width
        border.color: styleReader.background.border.color
    }
}
