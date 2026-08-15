pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.MenuItem {
    id: control

    property int colorSet: Ayame.Theme.header
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding + (implicitIndicatorWidth > 0 ? implicitIndicatorWidth + spacing : 0) + (arrow ? arrow.implicitWidth + spacing : 0))
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, Math.max(implicitContentHeight, implicitIndicatorHeight, arrow ? arrow.implicitHeight : 0) + topPadding + bottomPadding)

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.highlighted ? control.colors.highlightColor : "transparent"
    }

    contentItem: Text {
        leftPadding: Ayame.Units.smallSpacing + (control.checkable && control.indicator ? control.indicator.implicitWidth + control.spacing : 0)
        rightPadding: Ayame.Units.smallSpacing + (control.arrow ? control.arrow.implicitWidth + control.spacing : 0)
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
        elide: Text.ElideRight
    }

    // Without these, a checkable MenuItem never shows its checked state and
    // a submenu item never shows the arrow hinting it opens one -- same
    // missing-piece shape as ComboBox's missing indicator. Matches
    // QtQuick.Controls.Basic's own MenuItem.qml (glyphs instead of its
    // image assets, consistent with ComboBox.qml's own "▾" indicator here).
    indicator: Text {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        visible: control.checkable
        text: "✓"
        opacity: control.checked ? 1 : 0
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
    }

    arrow: Text {
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        visible: control.subMenu
        text: "▸"
        color: control.highlighted ? control.colors.highlightedTextColor : control.colors.textColor
    }
}
