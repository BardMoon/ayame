pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.SwipeDelegate {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    background: Rectangle {
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
