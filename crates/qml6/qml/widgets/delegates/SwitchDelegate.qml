pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.SwitchDelegate {
    id: control

    // Same split as CheckDelegate.qml/RadioDelegate.qml: background/text
    // reuse `itemDelegate`, indicator reuses `switchControl` (widgets/
    // controls/Switch.qml's own slot).
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
        controlType: LabsStyleKit.StyleReader.SwitchControl
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
        rightPadding: control.indicator ? control.indicator.width + control.spacing : 0
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
        implicitWidth: 36
        implicitHeight: 20
        x: control.width - width - control.rightPadding
        y: parent.height / 2 - height / 2
        radius: 10
        color: indicatorStyleReader.background.color
        border.width: indicatorStyleReader.background.border.width
        border.color: indicatorStyleReader.background.border.color

        Rectangle {
            x: control.checked ? parent.width - width - 2 : 2
            y: 2
            width: 16
            height: 16
            radius: 8
            color: control.checked ? control.palette.highlightedText : control.palette.text

            Behavior on x {
                NumberAnimation {
                    duration: 100
                }
            }
        }
    }
}
