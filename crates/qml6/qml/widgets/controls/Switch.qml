pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.Switch {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    spacing: Units.smallSpacing
    opacity: control.enabled ? 1.0 : 0.5

    indicator: Rectangle {
        implicitWidth: 36
        implicitHeight: 20
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 10
        color: control.checked ? control.colors.highlightColor : control.colors.backgroundColor
        border.width: Units.borderWidth
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

    contentItem: Text {
        leftPadding: control.indicator ? control.indicator.width + control.spacing : 0
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.colors.textColor
    }
}
