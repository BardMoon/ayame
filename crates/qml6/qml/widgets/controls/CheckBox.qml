pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.CheckBox {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)
    readonly property real _indicatorSize: Ayame.Units.iconSizes.small

    hoverEnabled: true
    spacing: Ayame.Units.smallSpacing
    opacity: control.enabled ? 1.0 : 0.5

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    indicator: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: control._indicatorSize
        height: control._indicatorSize
        radius: Ayame.Units.cornerRadius
        color: control.checked ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : "transparent")
        border.width: Ayame.Units.borderWidth
        border.color: control.checked ? control.colors.highlightColor : (control.hovered ? control.colors.hoverBorderColor : control.colors.borderColor)

        Text {
            anchors.centerIn: parent
            visible: control.checked
            text: "✓"
            font.pixelSize: parent.height * 0.8
            font.bold: true
            color: control.colors.highlightedTextColor
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
