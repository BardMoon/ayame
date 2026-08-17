pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.Menu {
    id: control

    property int colorSet: StyleKit.Theme.header
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    // T.Menu (like T.Popup, which it extends) never computes its own root
    // implicitWidth/implicitHeight from contentItem/background -- every
    // style has to bind both explicitly, same as every other widget file
    // in this module.
    //
    // implicitWidth reads `contentWidth` (a real Popup-family property,
    // defaulting to `contentItem ? contentItem.implicitWidth : 0`) rather
    // than reaching into contentItem itself -- confirmed against both Qt
    // 6.11.1's own QtQuick.Controls.Basic Menu.qml and qqc2-breeze-style's
    // Menu.qml, which both do the same. The actual per-item width
    // measurement lives on the ListView below (`implicitWidth:
    // contentItem.visibleChildren.reduce(...)`, where -- inside the
    // ListView's own binding scope -- `contentItem` unambiguously means
    // the ListView's own Flickable.contentItem, i.e. the real holder of
    // its rendered delegates), exactly matching qqc2-breeze-style's Menu.qml
    // (confirmed on disk). An earlier version of this file put that same
    // `visibleChildren.reduce` expression directly on *this* implicitWidth
    // instead: there, `contentItem` means this control's own contentItem
    // property (the ListView itself, one level shallower) whose direct
    // QML children are just its ScrollIndicator/HoverHandler -- always an
    // empty list, so implicitWidth silently fell back to just
    // padding/inset (~5px) -- the "DropdownButton/HamburgerButton menu
    // renders ~5px wide" bug. This applies whether contentItem is this
    // file's own default ListView below or a consumer's override (e.g.
    // origami's ThemedMenu.qml/ThemedSubMenu.qml, which already put the
    // same `visibleChildren.reduce` fix on their own ListView
    // independently) -- `contentWidth` picks up whichever is active.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)

    padding: StyleKit.Units.smallSpacing

    // Default delegate/contentItem for direct (non-wrapped) usage of this
    // type -- a consumer like origami's ThemedMenu.qml/ThemedSubMenu.qml
    // is free to override both, same as QtQuick.Controls.Basic's own
    // Menu.qml. T.Menu itself provides neither by default.
    delegate: MenuItem {}

    contentItem: ListView {
        implicitHeight: contentHeight
        implicitWidth: contentItem.visibleChildren.reduce((maxWidth, child) => Math.max(maxWidth, child.implicitWidth), 0)
        model: control.contentModel
        interactive: Window.window ? contentHeight + control.topPadding + control.bottomPadding > control.height : false
        clip: true
        currentIndex: control.currentIndex

        T.ScrollIndicator.vertical: Ayame.ScrollIndicator {}
    }

    background: Rectangle {
        radius: StyleKit.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: StyleKit.Units.borderWidth
        border.color: control.colors.borderColor
    }
}
