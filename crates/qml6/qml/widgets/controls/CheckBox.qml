pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.CheckBox {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)
    readonly property real _indicatorSize: StyleKit.Units.iconSizes.small

    hoverEnabled: true
    spacing: StyleKit.Units.smallSpacing
    opacity: control.enabled ? 1.0 : 0.5

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    indicator: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: control._indicatorSize
        height: control._indicatorSize
        radius: StyleKit.Units.cornerRadius
        clip: true
        color: control.checked ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : "transparent")
        border.width: StyleKit.Units.borderWidth
        border.color: control.checked ? control.colors.highlightColor : (control.hovered ? control.colors.hoverBorderColor : control.colors.borderColor)

        Text {
            // anchors.fill + alignment (not anchors.centerIn on an
            // implicitly-sized Text) so the glyph is centered against
            // the font's actual rendered bounds rather than the text
            // item's ascent/descent box, which for "✓" sat visibly
            // off-center.
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "✓"
            font.pixelSize: parent.height * 1.15
            font.weight: Font.Black
            color: control.colors.highlightedTextColor

            // Grows in from nothing on check, shrinks back out on
            // uncheck -- same feel as RadioButton's dot.
            scale: control.checked ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation { duration: StyleKit.Units.shortDuration; easing.type: Easing.OutCubic }
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
