pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.Tumbler {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    delegate: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: modelData
        font: control.font
        color: control.colors.textColor
        opacity: 0.4 + (1.0 - Math.abs(Tumbler.displacement) / (control.visibleItemCount / 2)) * 0.6
    }
}
