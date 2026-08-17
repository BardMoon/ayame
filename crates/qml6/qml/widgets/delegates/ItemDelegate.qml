pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.ItemDelegate {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    padding: StyleKit.Units.smallSpacing

    // See widgets/Button.qml's own icon.width/height for why this is here
    // despite contentItem below having no icon rendering yet.
    icon.width: StyleKit.Units.iconSizes.smallMedium
    icon.height: StyleKit.Units.iconSizes.smallMedium

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        radius: StyleKit.Units.cornerRadius
        color: control.pressed ? control.colors.pressedColor : (control.hovered ? control.colors.hoverColor : "transparent")
    }

    contentItem: Ayame.IconLabel {
        centered: false
        iconSource: control.icon.source
        iconWidth: control.icon.width
        iconHeight: control.icon.height
        display: control.display
        mirrored: control.mirrored
        spacing: StyleKit.Units.smallSpacing
        text: control.text
        font: control.font
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
        elide: Text.ElideRight
    }
}
