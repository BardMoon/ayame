pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.MenuItem {
    id: control

    // Same situation as Menu.qml right above it in this directory: no
    // AbstractStylableControls slot exists for MenuItem either, so its
    // header-colorSet text color is computed locally. `highlighted`'s
    // background/text swap reads straight off `control.palette.highlight`/
    // `.highlightedText` -- a direct pass-through, same as every other
    // highlight-state read in this migration (no blending involved).
    readonly property color _headerText: control.palette.buttonText

    hoverEnabled: true
    padding: StyleKit.Units.smallSpacing

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding + (implicitIndicatorWidth > 0 ? implicitIndicatorWidth + spacing : 0) + (arrow ? arrow.implicitWidth + spacing : 0))
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, Math.max(implicitContentHeight, implicitIndicatorHeight, arrow ? arrow.implicitHeight : 0) + topPadding + bottomPadding)

    background: Rectangle {
        radius: StyleKit.Units.cornerRadius
        color: control.highlighted ? control.palette.highlight : "transparent"
    }

    contentItem: Text {
        leftPadding: StyleKit.Units.smallSpacing + (control.checkable && control.indicator ? control.indicator.implicitWidth + control.spacing : 0)
        rightPadding: StyleKit.Units.smallSpacing + (control.arrow ? control.arrow.implicitWidth + control.spacing : 0)
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.highlighted ? control.palette.highlightedText : control._headerText
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
        color: control.highlighted ? control.palette.highlightedText : control._headerText
    }

    arrow: Text {
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        visible: control.subMenu
        text: "▸"
        color: control.highlighted ? control.palette.highlightedText : control._headerText
    }
}
