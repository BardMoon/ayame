pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Ayame 1.0

QQC2.Tumbler {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

    delegate: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: modelData
        font: control.font
        color: control.colors.textColor
        opacity: 0.4 + (1.0 - Math.abs(Tumbler.displacement) / (control.visibleItemCount / 2)) * 0.6
    }
}
