pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import Ayame 1.0 as Ayame

QQC2.ApplicationWindow {
    id: window

    property int colorSet: Ayame.Theme.window
    readonly property var colors: Ayame.Theme.paletteFor(window.colorSet)

    color: window.colors.backgroundColor
}
