pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Ayame 1.0 as Ayame

T.MenuItem {
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
