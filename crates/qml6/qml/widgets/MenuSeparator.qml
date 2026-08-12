pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.MenuSeparator {
    id: control

    property int colorSet: Theme.header
    readonly property var colors: Theme.paletteFor(control.colorSet)

    padding: Units.smallSpacing

    contentItem: Rectangle {
        implicitWidth: 100
        implicitHeight: 1
        color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.2)
    }
}
