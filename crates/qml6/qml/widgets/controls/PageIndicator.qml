pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.PageIndicator {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

    delegate: Rectangle {
        implicitWidth: 8
        implicitHeight: 8
        radius: 4
        color: index === control.currentIndex ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }
}
