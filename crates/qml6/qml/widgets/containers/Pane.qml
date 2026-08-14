pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Ayame 1.0 as Ayame

T.Pane {
    id: control

    property int colorSet: Ayame.Theme.window
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    background: Rectangle {
        color: control.colors.backgroundColor
    }
}
