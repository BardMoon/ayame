pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import Ayame 1.0 as Ayame

QQC2.AbstractButton {
    id: control

    property int colorSet: Ayame.Ayame.Theme.view
    readonly property var colors: Ayame.Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
}
