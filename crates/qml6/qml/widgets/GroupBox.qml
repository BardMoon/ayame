pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.GroupBox {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

    padding: Units.largeSpacing

    label: Label {
        x: control.leftPadding
        width: control.availableWidth
        text: control.title
        font.bold: true
        font: control.font
        color: control.colors.textColor
        elide: Text.ElideRight
    }

    background: Rectangle {
        y: control.topPadding - control.bottomPadding
        width: parent.width
        height: parent.height - control.topPadding + control.bottomPadding
        radius: Units.cornerRadius
        color: "transparent"
        border.width: Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }
}
