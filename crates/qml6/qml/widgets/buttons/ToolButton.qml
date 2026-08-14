pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.ToolButton {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    implicitHeight: Ayame.Units.gridUnit * 1.6
    implicitWidth: contentItem.implicitWidth + Ayame.Units.largeSpacing * 2

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : "transparent")
    }

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.pressed ? control.colors.highlightedTextColor : control.colors.textColor
    }
}
