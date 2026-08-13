pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Ayame 1.0

QQC2.ToolSeparator {
    id: control

    property int colorSet: Theme.header
    readonly property var colors: Theme.paletteFor(control.colorSet)

    contentItem: Rectangle {
        implicitWidth: control.vertical ? 1 : 8
        implicitHeight: control.vertical ? 8 : 1
        color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.2)
    }
}
