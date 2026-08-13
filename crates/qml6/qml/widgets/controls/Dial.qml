pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Ayame 1.0

QQC2.Dial {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    background: Rectangle {
        implicitWidth: Units.gridUnit * 3.5
        implicitHeight: Units.gridUnit * 3.5
        radius: width / 2
        color: control.colors.backgroundColor
        border.width: Units.borderWidth
        border.color: control.hovered ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    handle: Rectangle {
        id: handleItem
        x: control.background.x + control.background.width / 2 - width / 2
        y: control.background.y + control.background.height / 2 - height / 2
        width: 10
        height: 10
        radius: 5
        color: control.colors.highlightColor
        transform: [
            Translate {
                y: -control.background.height / 2 + 8
            },
            Rotation {
                angle: control.angle
                origin.x: handleItem.width / 2
                origin.y: handleItem.height / 2
            }
        ]
    }
}
