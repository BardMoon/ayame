pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.DelayButton {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitHeight: StyleKit.Units.gridUnit * 1.6
    implicitWidth: contentItem.implicitWidth + StyleKit.Units.largeSpacing * 2

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: StyleKit.Units.cornerRadius
            color: control.pressed ? control.colors.pressedColor : (control.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
            border.width: StyleKit.Units.borderWidth
            border.color: control.activeFocus ? control.colors.highlightColor : control.colors.borderColor
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
                color: control.colors.highlightColor
                opacity: 0.5
                border.width: StyleKit.Units.borderWidth
                border.color: control.colors.highlightColor
            }
        }
    }

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.colors.textColor
    }
}
