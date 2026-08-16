pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.TextArea {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    color: control.colors.textColor
    placeholderTextColor: control.colors.subColor
    selectedTextColor: control.colors.highlightedTextColor
    selectionColor: control.colors.highlightColor
    padding: Ayame.Units.smallSpacing

    implicitWidth: Math.max(contentWidth + leftPadding + rightPadding, implicitBackgroundWidth + leftInset + rightInset, placeholder.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset, placeholder.implicitHeight + topPadding + bottomPadding)

    T.ContextMenu.menu: Ayame.TextEditingContextMenu {
        editor: control
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: Ayame.Units.cornerRadius
            color: control.colors.backgroundColor
            border.width: Ayame.Units.borderWidth
            border.color: control.colors.borderColor
        }

        // Same activeFocus cue as widgets/Button.qml -- see
        // HighlightRing.qml -- TextArea has no `highlighted` state so
        // only the fade+pulse `active` ring applies here.
        Ayame.HighlightRing {
            anchors.fill: parent
            active: control.activeFocus
            ringColor: control.colors.highlightColor
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
