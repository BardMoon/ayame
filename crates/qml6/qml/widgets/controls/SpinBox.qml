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
    // The indicators' width is reserved via leftPadding/rightPadding below
    // (not added again here), same as QtQuick.Controls.Basic's own
    // SpinBox.qml -- otherwise it'd be double-counted.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)

    // Without this, contentItem (an interactive TextInput) spans the full
    // control width and overlaps up.indicator/down.indicator, which are
    // positioned at the left/right edges independently -- so it eats the
    // press events meant for the +/- buttons and increase()/decrease()
    // never fire. Same fix QtQuick.Controls.Basic's own SpinBox.qml
    // applies ("the width of the indicators are calculated into the
    // padding").
    leftPadding: padding + (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0))
    rightPadding: padding + (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0))

    // contentItem below reads control.validator; without a validator here
    // it stays null, so typing in an editable SpinBox never gets
    // constrained to the from/to range. Matches QtQuick.Controls.Basic's
    // own SpinBox.qml.
    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

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
