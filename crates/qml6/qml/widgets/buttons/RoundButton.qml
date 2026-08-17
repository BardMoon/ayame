pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.RoundButton {
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

    hoverEnabled: true

    // See widgets/Button.qml's own icon.width/height for why this is here
    // despite contentItem below having no icon rendering yet.
    icon.width: StyleKit.Units.iconSizes.smallMedium
    icon.height: StyleKit.Units.iconSizes.smallMedium

    implicitWidth: StyleKit.Units.gridUnit * 1.8
    implicitHeight: StyleKit.Units.gridUnit * 1.8
    radius: width / 2

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: control.radius
            color: styleReader.background.color
            border.width: styleReader.background.border.width
            border.color: styleReader.background.border.color
        }

        // Same highlighted/activeFocus cues as widgets/Button.qml -- see
        // HighlightRing.qml -- just with cornerRadius pinned to
        // control.radius so the ring/pulse stay circular here too.
        Ayame.HighlightRing {
            anchors.fill: parent
            cornerRadius: control.radius
            animating: control.enabled && control.highlighted && StyleKit.Units.animationsEnabled
            active: control.enabled && control.activeFocus
            ringColor: control.palette.highlight
        }
    }

    contentItem: Ayame.IconLabel {
        iconSource: control.icon.source
        iconWidth: control.icon.width
        iconHeight: control.icon.height
        display: control.display
        mirrored: control.mirrored
        spacing: StyleKit.Units.smallSpacing
        text: control.text
        font: control.font
        color: styleReader.text.color
    }
}
