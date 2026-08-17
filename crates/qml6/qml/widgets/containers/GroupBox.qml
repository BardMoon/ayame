pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.GroupBox {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    padding: StyleKit.Units.largeSpacing

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding, implicitLabelWidth)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    label: Ayame.Label {
        x: control.leftPadding
        width: control.availableWidth
        text: control.title
        font: Qt.font({ family: control.font.family, pointSize: control.font.pointSize, bold: true })
        color: control.colors.textColor
        elide: Text.ElideRight
    }

    background: Rectangle {
        y: control.topPadding - control.bottomPadding
        width: parent.width
        height: parent.height - control.topPadding + control.bottomPadding
        radius: StyleKit.Units.cornerRadius
        color: "transparent"
        border.width: StyleKit.Units.borderWidth
        border.color: control.colors.borderColor
    }
}
