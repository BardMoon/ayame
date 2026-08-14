pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.ComboBox {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitHeight: Ayame.Units.gridUnit * 1.6

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: Ayame.Units.borderWidth
        border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    contentItem: Text {
        leftPadding: Ayame.Units.smallSpacing
        rightPadding: control.indicator ? control.indicator.width + control.spacing : Ayame.Units.smallSpacing
        verticalAlignment: Text.AlignVCenter
        text: control.displayText
        font: control.font
        color: control.colors.textColor
        elide: Text.ElideRight
    }
}
