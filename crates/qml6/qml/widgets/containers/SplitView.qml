pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.SplitView {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    handle: Rectangle {
        implicitWidth: 4
        implicitHeight: 4
        color: SplitHandle.pressed ? control.colors.highlightColor : (SplitHandle.hovered ? control.colors.hoverColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.2))
    }
}
