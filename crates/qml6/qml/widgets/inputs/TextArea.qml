pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.TextArea {
    id: control

    // `textArea` has a dedicated slot, but its old look was identical to
    // `control`'s (view colorSet) -- no AyameStyle override needed.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.TextArea
        enabled: control.enabled
        focused: control.activeFocus
        palette: control.palette
    }

    // "subColor" (translucent text color) has no Qt.labs.StyleKit
    // equivalent, same as PageIndicator's dots -- kept as a local blend
    // off the live palette.
    readonly property color _subColor: Qt.rgba(control.palette.text.r, control.palette.text.g, control.palette.text.b, 0.3)

    color: styleReader.text.color
    placeholderTextColor: control._subColor
    selectedTextColor: control.palette.highlightedText
    selectionColor: control.palette.highlight
    padding: StyleKit.Units.smallSpacing

    implicitWidth: Math.max(contentWidth + leftPadding + rightPadding, implicitBackgroundWidth + leftInset + rightInset, placeholder.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset, placeholder.implicitHeight + topPadding + bottomPadding)

    T.ContextMenu.menu: Ayame.TextEditingContextMenu {
        editor: control
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: StyleKit.Units.cornerRadius
            color: styleReader.background.color
            border.width: styleReader.background.border.width
            border.color: styleReader.background.border.color
        }

        // Same activeFocus cue as widgets/Button.qml -- see
        // HighlightRing.qml -- TextArea has no `highlighted` state so
        // only the fade+pulse `active` ring applies here.
        Ayame.HighlightRing {
            anchors.fill: parent
            active: control.activeFocus
            ringColor: control.palette.highlight
        }
    }

    // T.TextArea never renders `placeholderText` on its own -- see
    // TextField.qml's own comment for why this item is needed.
    Text {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - control.leftPadding - control.rightPadding
        height: control.height - control.topPadding - control.bottomPadding

        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        visible: !control.length && !control.preeditText && control.placeholderText.length > 0
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
    }
}
