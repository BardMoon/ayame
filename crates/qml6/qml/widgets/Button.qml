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
            color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
            border.width: Ayame.Units.borderWidth
            border.color: (control.pressed || control.activeFocus) ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, control.hovered ? 0.4 : 0.3)
        }

        // Spinning highlight ring, replacing the old static
        // activeFocus-turns-the-border-highlightColor treatment: a bright
        // arc chases around the border while the control is highlighted.
        // See HighlightRing.qml for the shape/animation itself.
        Ayame.HighlightRing {
            anchors.fill: parent
            animating: control.enabled && control.highlighted && Ayame.Units.animationsEnabled
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
        color: control.pressed ? control.colors.highlightedTextColor : control.colors.textColor

        Behavior on color {
            ColorAnimation { duration: Ayame.Units.shortDuration; easing.type: Easing.OutCubic }
        }
    }
}
