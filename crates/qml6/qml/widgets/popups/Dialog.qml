pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.Dialog {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    padding: StyleKit.Units.largeSpacing

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding, implicitHeaderWidth, implicitFooterWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0) + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))

    background: Rectangle {
        radius: StyleKit.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: StyleKit.Units.borderWidth
        border.color: control.colors.borderColor
    }

    header: Ayame.Label {
        text: control.title
        font.bold: true
        font.pointSize: StyleKit.Units.gridUnit * 0.75
        visible: control.title.length > 0
        padding: StyleKit.Units.largeSpacing
    }
}
