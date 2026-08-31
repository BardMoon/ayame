pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.TabButton {
    id: control

    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.TabButton
        enabled: control.enabled
        focused: control.activeFocus
        checked: control.checked
        hovered: control.hovered
        pressed: control.pressed
        palette: control.palette
    }

    hoverEnabled: true

    // See widgets/Button.qml's own icon.width/height for why this is here
    // despite contentItem below having no icon rendering yet.
    icon.width: StyleKit.Units.iconSizes.smallMedium
    icon.height: StyleKit.Units.iconSizes.smallMedium

    implicitHeight: StyleKit.Units.gridUnit * 1.6
    implicitWidth: contentItem.implicitWidth + StyleKit.Units.largeSpacing * 2
    leftPadding: StyleKit.Units.largeSpacing
    rightPadding: StyleKit.Units.largeSpacing

    // The checked-tab underline itself now lives in TabBar.qml (a single
    // indicator that slides between tabs) -- this only needs the
    // subtle hover/press wash.
    background: Rectangle {
        color: styleReader.background.color
    }

    contentItem: Ayame.IconLabel {
        iconSource: control.icon.source
        iconWidth: control.icon.width
        iconHeight: control.icon.height
        display: control.display
        mirrored: control.mirrored
        spacing: StyleKit.Units.smallSpacing
        text: control.text
        font: control.font
        color: styleReader.text.color
    }
}
