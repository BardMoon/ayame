pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Ayame 1.0

QQC2.SwipeView {
    id: control

    property int colorSet: Theme.window
    readonly property var colors: Theme.paletteFor(control.colorSet)
}
