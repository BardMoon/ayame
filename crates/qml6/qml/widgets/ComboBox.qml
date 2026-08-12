pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.ComboBox {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitHeight: Units.gridUnit * 1.6

    background: Rectangle {
        radius: Units.cornerRadius
        color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
        border.width: Units.borderWidth
        border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    contentItem: Text {
        leftPadding: Units.smallSpacing
        rightPadding: control.indicator ? control.indicator.width + control.spacing : Units.smallSpacing
        verticalAlignment: Text.AlignVCenter
        text: control.displayText
        font: control.font
        color: control.colors.textColor
        elide: Text.ElideRight
    }
}
