pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.SwipeView {
    id: control

    property int colorSet: Ayame.Theme.window
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)
}
