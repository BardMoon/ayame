pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.Dial {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    background: Rectangle {
        implicitWidth: Ayame.Units.gridUnit * 3.5
        implicitHeight: Ayame.Units.gridUnit * 3.5
        radius: width / 2
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
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
