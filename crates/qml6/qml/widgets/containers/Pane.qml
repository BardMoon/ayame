pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Pane {
    id: control

    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Pane
        enabled: control.enabled
        palette: control.palette
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        color: styleReader.background.color
    }
}
