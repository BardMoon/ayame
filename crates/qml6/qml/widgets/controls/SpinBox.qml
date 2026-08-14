pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.SpinBox {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitHeight: Ayame.Units.gridUnit * 1.6
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding + (up.indicator ? up.indicator.implicitWidth : 0) + (down.indicator ? down.indicator.implicitWidth : 0))

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    contentItem: TextInput {
        text: control.displayText
        font: control.font
        color: control.colors.textColor
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        implicitWidth: Ayame.Units.gridUnit * 1.2
        radius: Ayame.Units.cornerRadius
        color: control.up.pressed ? control.colors.highlightColor : (control.up.hovered ? control.colors.hoverColor : "transparent")

        Text {
            text: "+"
            anchors.centerIn: parent
            color: control.colors.textColor
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: Ayame.Units.gridUnit * 1.2
        radius: Ayame.Units.cornerRadius
        color: control.down.pressed ? control.colors.highlightColor : (control.down.hovered ? control.colors.hoverColor : "transparent")

        Text {
            text: "-"
            anchors.centerIn: parent
            color: control.colors.textColor
        }
    }
}
