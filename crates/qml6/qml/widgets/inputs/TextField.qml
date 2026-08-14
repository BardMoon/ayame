pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.TextField {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    color: control.colors.textColor
    placeholderTextColor: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.5)
    selectedTextColor: control.colors.highlightedTextColor
    selectionColor: control.colors.highlightColor
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: Ayame.Units.smallSpacing
    rightPadding: Ayame.Units.smallSpacing

    implicitHeight: Ayame.Units.gridUnit * 1.6
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding, placeholder.implicitWidth + leftPadding + rightPadding)

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
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
