pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.SwipeDelegate {
    id: control

    // No dedicated StyleReader.ControlType for SwipeDelegate -- reuses
    // `itemDelegate` (same background/text shape, no indicator of its
    // own), same reasoning as CheckDelegate/RadioDelegate/SwitchDelegate.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.ItemDelegate
        enabled: control.enabled
        focused: control.activeFocus
        highlighted: control.highlighted
        hovered: control.hovered
        pressed: control.pressed
        palette: control.palette
    }

    hoverEnabled: true
    padding: StyleKit.Units.smallSpacing

    // See widgets/Button.qml's own icon.width/height for why this is here
    // despite contentItem below having no icon rendering yet.
    icon.width: StyleKit.Units.iconSizes.smallMedium
    icon.height: StyleKit.Units.iconSizes.smallMedium

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        color: styleReader.background.color
    }

    contentItem: Ayame.IconLabel {
        centered: false
        iconSource: control.icon.source
        iconWidth: control.icon.width
        iconHeight: control.icon.height
        display: control.display
        mirrored: control.mirrored
        spacing: StyleKit.Units.smallSpacing
        text: control.text
        font: control.font
        color: styleReader.text.color
        elide: Text.ElideRight
    }
}
