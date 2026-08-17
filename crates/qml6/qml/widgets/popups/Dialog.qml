pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Dialog {
    id: control

    // StyleReader.ControlType.Dialog exists but has no matching
    // AbstractStylableControls slot (same situation as Menu.qml) -- falls
    // back to `control`, which is the exact same view-colorSet look this
    // file had before, so no local color computation needed here unlike
    // Menu.qml/MenuItem.qml (those needed *header* colors, which really
    // do differ from `control`'s view-colorSet default).
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Dialog
        enabled: control.enabled
        palette: control.palette
    }

    padding: StyleKit.Units.largeSpacing

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding, implicitHeaderWidth, implicitFooterWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0) + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))

    background: Rectangle {
        radius: styleReader.background.radius
        color: styleReader.background.color
        border.width: styleReader.background.border.width
        border.color: styleReader.background.border.color
    }

    header: Ayame.Label {
        text: control.title
        font.bold: true
        font.pointSize: StyleKit.Units.gridUnit * 0.75
        visible: control.title.length > 0
        padding: StyleKit.Units.largeSpacing
    }
}
