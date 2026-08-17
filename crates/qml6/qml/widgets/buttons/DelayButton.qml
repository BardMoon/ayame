pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.DelayButton {
    id: control

    hoverEnabled: true
    implicitHeight: StyleKit.Units.gridUnit * 1.6
    implicitWidth: contentItem.implicitWidth + StyleKit.Units.largeSpacing * 2

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

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: StyleKit.Units.cornerRadius
            color: styleReader.background.color
            border.width: styleReader.background.border.width
            border.color: styleReader.background.border.color
        }

        // Sweeps a highlighted border + tinted fill in from the left as
        // control.progress grows to 1 -- the same solid-highlight look
        // as HighlightRing's `active` cue, but revealed by clipping a
        // full-size highlighted copy of the background instead of
        // fading one in.
        Item {
            width: control.width * control.progress
            height: control.height
            clip: true

            Rectangle {
                width: control.width
                height: control.height
                radius: StyleKit.Units.cornerRadius
                color: control.palette.highlight
                opacity: 0.5
                border.width: styleReader.background.border.width
                border.color: control.palette.highlight
            }
        }
    }

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: styleReader.text.color
    }
}
