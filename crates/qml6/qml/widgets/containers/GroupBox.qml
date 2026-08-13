pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import Ayame 1.0 as Ayame

QQC2.GroupBox {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    padding: Ayame.Units.largeSpacing

    label: Ayame.Label {
        x: control.leftPadding
        width: control.availableWidth
        text: control.title
        font: Qt.font({ family: control.font.family, pointSize: control.font.pointSize, bold: true })
        color: control.colors.textColor
        elide: Text.ElideRight
    }

    background: Rectangle {
        y: control.topPadding - control.bottomPadding
        width: parent.width
        height: parent.height - control.topPadding + control.bottomPadding
        radius: Ayame.Units.cornerRadius
        color: "transparent"
        border.width: Ayame.Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }
}
