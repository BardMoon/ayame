pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Ayame 1.0 as Ayame

T.DelayButton {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitHeight: Ayame.Units.gridUnit * 1.6
    implicitWidth: contentItem.implicitWidth + Ayame.Units.largeSpacing * 2

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: Ayame.Units.borderWidth
        border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)

        Rectangle {
            width: parent.width * control.progress
            height: parent.height
            radius: Ayame.Units.cornerRadius
            color: control.colors.highlightColor
            opacity: 0.5
        }
    }

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.colors.textColor
    }
}
