pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.SwitchDelegate {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    background: Rectangle {
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : "transparent")
    }

    contentItem: Text {
        leftPadding: control.indicator ? control.indicator.width + control.spacing : 0
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
    }

    indicator: Rectangle {
        implicitWidth: 36
        implicitHeight: 20
        x: control.width - width - control.rightPadding
        y: parent.height / 2 - height / 2
        radius: 10
        color: control.checked ? control.colors.highlightColor : control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: control.checked ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)

        Rectangle {
            x: control.checked ? parent.width - width - 2 : 2
            y: 2
            width: 16
            height: 16
            radius: 8
            color: control.checked ? control.colors.highlightedTextColor : control.colors.textColor

            Behavior on x {
                NumberAnimation {
                    duration: 100
                }
            }
        }
    }
}
