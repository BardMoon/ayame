pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.ApplicationWindow {
    id: window

    property int colorSet: StyleKit.Theme.window
    readonly property var colors: StyleKit.Theme.paletteFor(window.colorSet)

    color: window.colors.backgroundColor
}
