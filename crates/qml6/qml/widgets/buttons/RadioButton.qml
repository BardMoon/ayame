pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Ayame 1.0

QQC2.RadioButton {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)
    readonly property real _indicatorSize: Units.iconSizes.small

    hoverEnabled: true
    spacing: Units.smallSpacing
    opacity: control.enabled ? 1.0 : 0.5

    indicator: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: control._indicatorSize
        height: control._indicatorSize
        radius: width / 2
        color: "transparent"
        border.width: Units.borderWidth
        border.color: control.checked ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, control.hovered ? 0.4 : 0.3)

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: parent.height * 0.5
            radius: width / 2
            visible: control.checked
            color: control.colors.highlightColor
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
