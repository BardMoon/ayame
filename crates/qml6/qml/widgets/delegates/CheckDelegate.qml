pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.CheckDelegate {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    background: Rectangle {
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : "transparent")
    }

    contentItem: Text {
        leftPadding: control.indicator ? control.indicator.width + control.spacing : 0
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
    }

    indicator: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: Ayame.Units.iconSizes.small
        height: Ayame.Units.iconSizes.small
        radius: Ayame.Units.cornerRadius
        color: control.checked ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : "transparent")
        border.width: Ayame.Units.borderWidth
        border.color: control.checked ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)

        Text {
            anchors.centerIn: parent
            visible: control.checked
            text: "✓"
            font.pixelSize: parent.height * 0.8
            font.bold: true
            color: control.colors.highlightedTextColor
        }
    }
}
