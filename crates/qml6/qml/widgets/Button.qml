pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.Button {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    opacity: control.enabled ? 1.0 : 0.5

    // Not rendered by contentItem below (no icon support yet), but without
    // a default here `control.icon.width`/`.height` stay at Qt's
    // documented default (0), so anything reading the icon's own size
    // (e.g. Layout sizing on a future icon Image) sees a bogus 0x0.
    // Matches QtQuick.Controls.Basic's own Button.qml (24x24 there).
    icon.width: Ayame.Units.iconSizes.smallMedium
    icon.height: Ayame.Units.iconSizes.smallMedium

    implicitHeight: Ayame.Units.gridUnit * 1.6
    implicitWidth: contentItem.implicitWidth + Ayame.Units.largeSpacing * 2

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: Ayame.Units.cornerRadius
            color: control.pressed ? control.colors.pressedColor : (control.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
            border.width: Ayame.Units.borderWidth
            border.color: control.hovered ? control.colors.hoverBorderColor : control.colors.borderColor
        }

        // Highlighted -> a bright arc chases around the border in an
        // infinite loop. activeFocus -> a solid border fades in/out,
        // replacing the old instant activeFocus-swaps-border-to-
        // highlightColor treatment. See HighlightRing.qml for both.
        Ayame.HighlightRing {
            anchors.fill: parent
            animating: control.enabled && control.highlighted && Ayame.Units.animationsEnabled
            active: control.enabled && control.activeFocus
            ringColor: control.colors.highlightColor
        }
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

        Behavior on color {
            ColorAnimation { duration: Ayame.Units.shortDuration; easing.type: Easing.OutCubic }
        }
    }
}
