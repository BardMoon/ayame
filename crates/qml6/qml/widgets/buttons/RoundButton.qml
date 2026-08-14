pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.RoundButton {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitWidth: Ayame.Units.gridUnit * 1.8
    implicitHeight: Ayame.Units.gridUnit * 1.8
    radius: width / 2

    background: Rectangle {
        radius: control.radius
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: Ayame.Units.borderWidth
        border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.pressed ? control.colors.highlightedTextColor : control.colors.textColor
    }
}
