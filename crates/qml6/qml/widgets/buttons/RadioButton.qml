pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.RadioButton {
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
        y: control.topPadding + Math.round((control.availableHeight - height) / 2)
        width: control._indicatorSize
        height: control._indicatorSize
        radius: width / 2
        color: "transparent"
        border.width: Ayame.Units.borderWidth
        border.color: control.checked ? control.colors.highlightColor : (control.hovered ? control.colors.hoverBorderColor : control.colors.borderColor)

        Rectangle {
            // Rounded independently (not just `parent.width * 0.5`) and
            // re-centered via explicit, separately-rounded x/y instead of
            // anchors.centerIn: at odd _indicatorSize/uiScale combinations
            // the raw half-size and its centering offset both land on
            // fractional pixels, and the two fractional roundings don't
            // always cancel out the same way on screen, which is what
            // made the dot look off-center at some UI scales.
            width: Math.round(parent.width * 0.5)
            height: Math.round(parent.height * 0.5)
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
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
