pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.TextArea {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    color: control.colors.textColor
    placeholderTextColor: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.5)
    selectedTextColor: control.colors.highlightedTextColor
    selectionColor: control.colors.highlightColor
    padding: Ayame.Units.smallSpacing

    implicitWidth: Math.max(contentWidth + leftPadding + rightPadding, implicitBackgroundWidth + leftInset + rightInset, placeholder.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset, placeholder.implicitHeight + topPadding + bottomPadding)

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
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
