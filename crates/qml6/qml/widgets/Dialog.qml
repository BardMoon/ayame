pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.Dialog {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

    padding: Units.largeSpacing

    background: Rectangle {
        radius: Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    header: Label {
        text: control.title
        font.bold: true
        font.pointSize: Units.gridUnit * 0.75
        visible: control.title.length > 0
        padding: Units.largeSpacing
    }
}
