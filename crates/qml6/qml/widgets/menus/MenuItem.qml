pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.MenuItem {
    id: control

    property int colorSet: Ayame.Theme.header
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding + (implicitIndicatorWidth > 0 ? implicitIndicatorWidth + spacing : 0) + (implicitArrowWidth > 0 ? implicitArrowWidth + spacing : 0))
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, Math.max(implicitContentHeight, implicitIndicatorHeight, implicitArrowHeight) + topPadding + bottomPadding)

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.highlighted ? control.colors.highlightColor : "transparent"
    }

    contentItem: Text {
        leftPadding: Ayame.Units.smallSpacing
        rightPadding: Ayame.Units.smallSpacing
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
        elide: Text.ElideRight
    }
}
