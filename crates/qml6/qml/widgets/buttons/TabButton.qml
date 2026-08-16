pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.TabButton {
    id: control

    property int colorSet: Ayame.Theme.header
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    // See widgets/Button.qml's own icon.width/height for why this is here
    // despite contentItem below having no icon rendering yet.
    icon.width: Ayame.Units.iconSizes.smallMedium
    icon.height: Ayame.Units.iconSizes.smallMedium

    implicitHeight: Ayame.Units.gridUnit * 1.6
    implicitWidth: contentItem.implicitWidth + Ayame.Units.largeSpacing * 2
    leftPadding: Ayame.Units.largeSpacing
    rightPadding: Ayame.Units.largeSpacing

    // The checked-tab underline itself now lives in TabBar.qml (a single
    // indicator that slides between tabs) -- this only needs the
    // subtle hover/press wash.
    background: Rectangle {
        color: control.pressed ? control.colors.pressedColor : (control.hovered ? control.colors.hoverColor : "transparent")
    }

    contentItem: Ayame.IconLabel {
        iconSource: control.icon.source
        iconWidth: control.icon.width
        iconHeight: control.icon.height
        display: control.display
        mirrored: control.mirrored
        spacing: Ayame.Units.smallSpacing
        text: control.text
        font: control.font
        color: control.colors.textColor
    }
}
