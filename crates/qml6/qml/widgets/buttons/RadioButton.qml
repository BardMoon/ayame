pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.RadioButton {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)
    // Snapped to a multiple of 4, not just to a whole pixel: the
    // indicator below is halved once for its own size and halved again
    // (implicitly, via (outer - inner) / 2) to center the checked dot,
    // so only a multiple-of-4 size guarantees both halvings land on
    // whole pixels with zero rounding -- a plain Math.round() on the
    // raw icon size still left a systematic ~0.5px centering bias at
    // some uiScale values, since outer/2 could come out odd.
    readonly property real _indicatorSize: Math.round(Ayame.Units.iconSizes.small / 4) * 4

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
            // parent.width is always a multiple of 4 (see _indicatorSize
            // above), so both of these divisions land exactly on whole
            // pixels -- no Math.round() needed, and no rounding bias left
            // to make the dot look off-center.
            width: parent.width * 0.5
            height: parent.height * 0.5
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            radius: width / 2
            color: control.colors.highlightColor

            // Grows in from nothing on check, shrinks back out on
            // uncheck, instead of popping straight to full size --
            // scale (not visible/opacity) so it actually animates.
            scale: control.checked ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation { duration: Ayame.Units.shortDuration; easing.type: Easing.OutCubic }
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
