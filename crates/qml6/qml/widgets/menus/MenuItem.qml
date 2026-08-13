pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import Ayame 1.0 as Ayame

QQC2.MenuItem {
    id: control

    property int colorSet: Ayame.Theme.header
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.highlighted ? control.colors.highlightColor : "transparent"
    }

    contentItem: Text {
        leftPadding: Ayame.Units.smallSpacing
        rightPadding: Ayame.Units.smallSpacing
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
        elide: Text.ElideRight
    }
}
