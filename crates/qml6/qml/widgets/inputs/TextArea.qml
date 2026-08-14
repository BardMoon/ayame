pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Ayame 1.0 as Ayame

T.TextArea {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    color: control.colors.textColor
    placeholderTextColor: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.5)
    selectedTextColor: control.colors.highlightedTextColor
    selectionColor: control.colors.highlightColor

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }
}
