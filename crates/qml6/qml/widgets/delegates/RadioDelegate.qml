pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.RadioDelegate {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    // See widgets/Button.qml's own icon.width/height for why this is here
    // despite contentItem below having no icon rendering yet.
    icon.width: Ayame.Units.iconSizes.smallMedium
    icon.height: Ayame.Units.iconSizes.smallMedium

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : "transparent")
    }

    contentItem: Ayame.IconLabel {
        centered: false
        leftPadding: control.indicator ? control.indicator.width + control.spacing : 0
        iconSource: control.icon.source
        iconWidth: control.icon.width
        iconHeight: control.icon.height
        display: control.display
        mirrored: control.mirrored
        spacing: Ayame.Units.smallSpacing
        text: control.text
        font: control.font
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
    }

    indicator: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: Ayame.Units.iconSizes.small
        height: Ayame.Units.iconSizes.small
        radius: width / 2
        color: "transparent"
        border.width: Ayame.Units.borderWidth
        border.color: control.checked ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: parent.height * 0.5
            radius: width / 2
            visible: control.checked
            color: control.colors.highlightColor
        }
    }
}
