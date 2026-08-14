pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.Menu {
    id: control

    property int colorSet: Ayame.Theme.header
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    // T.Menu (like T.Popup, which it extends) never computes its own root
    // implicitWidth/implicitHeight from contentItem/background -- every
    // style has to bind both explicitly, same as every other widget file
    // in this module (see docs/qqc2-custom-style-resolution.md's sibling
    // investigation into the T-templates migration for the general
    // pattern). implicitWidth additionally can't just use
    // implicitContentWidth/contentWidth here: those only account for
    // Action-backed entries, not plain MenuItem children -- see qqc2-
    // breeze-style's own Menu.qml, which applies the same
    // visibleChildren-reduce fix for the same reason. This matters even
    // more once a consumer overrides `contentItem` with its own ListView
    // (e.g. origami's ThemedMenu.qml/ThemedSubMenu.qml) -- without an
    // explicit implicitHeight binding here, that override's menu
    // collapsed to 0 height and never appeared at all, while other
    // Popup-family widgets (which do bind implicitHeight) kept working.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentItem.visibleChildren.reduce((maxWidth, child) => Math.max(maxWidth, child.implicitWidth), 0) + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)

    padding: Ayame.Units.smallSpacing

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }
}
