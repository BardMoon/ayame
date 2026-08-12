pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.Page {
    id: control

    property int colorSet: Theme.window
    readonly property var colors: Theme.paletteFor(control.colorSet)

    background: Rectangle {
        color: control.colors.backgroundColor
    }
}
