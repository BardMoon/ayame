pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.MenuItem {
    id: control

    property int colorSet: Theme.header
    readonly property var colors: Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    background: Rectangle {
        radius: Units.cornerRadius
        color: control.highlighted ? control.colors.highlightColor : "transparent"
    }

    contentItem: Text {
        leftPadding: Units.smallSpacing
        rightPadding: Units.smallSpacing
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
        elide: Text.ElideRight
    }
}
