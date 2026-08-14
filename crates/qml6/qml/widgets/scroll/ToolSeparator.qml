pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.ToolSeparator {
    id: control

    property int colorSet: Ayame.Theme.header
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    contentItem: Rectangle {
        implicitWidth: control.vertical ? 1 : 8
        implicitHeight: control.vertical ? 8 : 1
        color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.2)
    }
}
