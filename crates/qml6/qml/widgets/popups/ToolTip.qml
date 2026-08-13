pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Ayame 1.0

QQC2.ToolTip {
    id: control

    property int colorSet: Theme.tooltip
    readonly property var colors: Theme.paletteFor(control.colorSet)

    padding: Units.smallSpacing

    background: Rectangle {
        radius: Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.colors.textColor
    }
}
