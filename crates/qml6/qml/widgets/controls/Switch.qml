pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.Switch {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    // Proportioned off gridUnit (not hardcoded px) so the switch scales
    // with uiScale like every other control here, same 36:20:16:2 ratio
    // the old hardcoded numbers had.
    readonly property real _trackHeight: Ayame.Units.gridUnit
    readonly property real _trackWidth: Math.round(control._trackHeight * 1.8)
    readonly property real _thumbMargin: Math.max(1, Math.round(control._trackHeight * 0.1))
    readonly property real _thumbSize: control._trackHeight - control._thumbMargin * 2

    hoverEnabled: true
    spacing: Ayame.Units.smallSpacing
    opacity: control.enabled ? 1.0 : 0.5

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    indicator: Rectangle {
        implicitWidth: control._trackWidth
        implicitHeight: control._trackHeight
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: height / 2
        color: control.checked ? control.colors.highlightColor : control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: control.checked ? control.colors.highlightColor : (control.hovered ? control.colors.hoverBorderColor : control.colors.borderColor)

        Rectangle {
            x: control.checked ? parent.width - width - control._thumbMargin : control._thumbMargin
            y: control._thumbMargin
            width: control._thumbSize
            height: control._thumbSize
            radius: width / 2
            color: control.checked ? control.colors.highlightedTextColor : control.colors.textColor

            Behavior on x {
                NumberAnimation { duration: Ayame.Units.shortDuration; easing.type: Easing.OutCubic }
            }
            Behavior on color {
                ColorAnimation { duration: Ayame.Units.shortDuration; easing.type: Easing.OutCubic }
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
