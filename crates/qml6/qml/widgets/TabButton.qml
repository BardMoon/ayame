pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.TabButton {
    id: control

    property int colorSet: Theme.header
    readonly property var colors: Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    background: Rectangle {
        color: control.checked ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : "transparent")
    }

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.checked ? control.colors.highlightedTextColor : control.colors.textColor
    }
}
