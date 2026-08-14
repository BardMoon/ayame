pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.ItemDelegate {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : "transparent")
    }

    contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
        elide: Text.ElideRight
    }
}
