pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.TextField {
    id: control

    // `textField` has a dedicated slot, but its old look was identical to
    // `control`'s (view colorSet) -- no AyameStyle override needed.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.TextField
        enabled: control.enabled
        focused: control.activeFocus
        palette: control.palette
    }

    // Same local blend as TextArea.qml's own placeholderTextColor.
    readonly property color _subColor: Qt.rgba(control.palette.text.r, control.palette.text.g, control.palette.text.b, 0.3)

    color: styleReader.text.color
    placeholderTextColor: control._subColor
    selectedTextColor: control.palette.highlightedText
    selectionColor: control.palette.highlight
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: StyleKit.Units.smallSpacing
    rightPadding: StyleKit.Units.smallSpacing

    implicitHeight: StyleKit.Units.gridUnit * 1.6
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding, placeholder.implicitWidth + leftPadding + rightPadding)

    T.ContextMenu.menu: Ayame.TextEditingContextMenu {
        editor: control
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: styleReader.background.radius
            color: styleReader.background.color
            border.width: styleReader.background.border.width
            border.color: styleReader.background.border.color
        }

        // Same activeFocus cue as widgets/Button.qml -- see
        // HighlightRing.qml -- TextField has no `highlighted` state so
        // only the fade+pulse `active` ring applies here.
        Ayame.HighlightRing {
            anchors.fill: parent
            active: control.activeFocus
            ringColor: control.palette.highlight
        }
    }

    // T.TextField never renders `placeholderText` on its own -- every
    // style has to draw it itself (same as
    // QtQuick.Controls.Basic's own TextField.qml's PlaceholderText).
    // `placeholderTextColor` above was previously set but had nothing
    // reading it, since there was no such item at all.
    Text {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - control.leftPadding - control.rightPadding
        height: control.height - control.topPadding - control.bottomPadding

        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        verticalAlignment: control.verticalAlignment
        visible: !control.length && !control.preeditText && control.placeholderText.length > 0
        elide: Text.ElideRight
    }
}
