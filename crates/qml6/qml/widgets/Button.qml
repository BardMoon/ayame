pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Button {
    id: control

    hoverEnabled: true
    opacity: control.enabled ? 1.0 : 0.5

    // Not rendered by contentItem below (no icon support yet), but without
    // a default here `control.icon.width`/`.height` stay at Qt's
    // documented default (0), so anything reading the icon's own size
    // (e.g. Layout sizing on a future icon Image) sees a bogus 0x0.
    // Matches QtQuick.Controls.Basic's own Button.qml (24x24 there).
    icon.width: StyleKit.Units.iconSizes.smallMedium
    icon.height: StyleKit.Units.iconSizes.smallMedium

    implicitHeight: StyleKit.Units.gridUnit * 1.6
    implicitWidth: contentItem.implicitWidth + StyleKit.Units.largeSpacing * 2

    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: control.flat ? LabsStyleKit.StyleReader.FlatButton : LabsStyleKit.StyleReader.Button
        enabled: control.enabled
        focused: control.activeFocus
        checked: control.checked
        hovered: control.hovered
        pressed: control.pressed
        palette: control.palette
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: styleReader.background.radius
            color: styleReader.background.color
            border.width: styleReader.background.border.width
            border.color: styleReader.background.border.color
        }

        // Highlighted -> a bright arc chases around the border in an
        // infinite loop. activeFocus -> a solid border fades in/out,
        // replacing the old instant activeFocus-swaps-border-to-
        // highlightColor treatment. See HighlightRing.qml for both.
        Ayame.HighlightRing {
            anchors.fill: parent
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

        Behavior on color {
            ColorAnimation { duration: StyleKit.Units.shortDuration; easing.type: Easing.OutCubic }
        }
    }
}
