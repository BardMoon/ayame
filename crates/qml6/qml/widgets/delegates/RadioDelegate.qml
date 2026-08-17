pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.RadioDelegate {
    id: control

    // Same split as CheckDelegate.qml right above it: background/text
    // reuse `itemDelegate`, indicator reuses `radioButton` (widgets/
    // buttons/RadioButton.qml's own slot).
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.ItemDelegate
        enabled: control.enabled
        focused: control.activeFocus
        highlighted: control.highlighted
        hovered: control.hovered
        pressed: control.pressed
        palette: control.palette
    }

    LabsStyleKit.StyleReader {
        id: indicatorStyleReader
        controlType: LabsStyleKit.StyleReader.RadioButton
        enabled: control.enabled
        checked: control.checked
        hovered: control.hovered
        palette: control.palette
    }

    hoverEnabled: true
    padding: StyleKit.Units.smallSpacing

    // See widgets/Button.qml's own icon.width/height for why this is here
    // despite contentItem below having no icon rendering yet.
    icon.width: StyleKit.Units.iconSizes.smallMedium
    icon.height: StyleKit.Units.iconSizes.smallMedium

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Rectangle {
        color: styleReader.background.color
    }

    contentItem: Ayame.IconLabel {
        centered: false
        leftPadding: control.indicator ? control.indicator.width + control.spacing : 0
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

    indicator: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: StyleKit.Units.iconSizes.small
        height: StyleKit.Units.iconSizes.small
        radius: width / 2
        color: "transparent"
        border.width: indicatorStyleReader.background.border.width
        border.color: indicatorStyleReader.background.border.color

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: parent.height * 0.5
            radius: width / 2
            visible: control.checked
            color: control.palette.highlight
        }
    }
}
