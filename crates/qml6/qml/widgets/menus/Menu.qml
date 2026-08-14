pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.Menu {
    id: control

    property int colorSet: Ayame.Theme.header
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    // T.Menu's own default contentItem (a ListView over control.contentModel)
    // binds implicitHeight (contentHeight) but never implicitWidth -- every
    // MenuItem's own real text width would otherwise stay invisible, the
    // Menu itself collapsing down to just padding/insets. Same fix
    // qqc2-breeze-style's own Menu.qml applies, with the same comment
    // explaining why contentWidth alone doesn't work: it only accounts for
    // Action-backed entries, not plain MenuItem children.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentItem.visibleChildren.reduce((maxWidth, child) => Math.max(maxWidth, child.implicitWidth), 0) + leftPadding + rightPadding)

    padding: Ayame.Units.smallSpacing

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }
}
