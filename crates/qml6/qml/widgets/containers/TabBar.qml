pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.TabBar {
    id: control

    property int colorSet: Ayame.Theme.header
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    // T.TabBar (a plain Container) has no built-in layout for the buttons
    // in its contentModel -- without this, every TabButton stacks at the
    // same position instead of appearing side by side. Same ListView-over-
    // contentModel idiom as QtQuick.Controls.Basic's own TabBar.qml.
    contentItem: ListView {
        id: tabsView
        model: control.contentModel
        currentIndex: control.currentIndex
        spacing: control.spacing
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded
        snapMode: ListView.SnapToItem
        highlightMoveDuration: 250
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 48
        preferredHighlightEnd: width - 48
    }

    background: Rectangle {
        color: control.colors.backgroundColor

        // The checked tab's underline, moved up here from TabButton.qml
        // so there's a single indicator that slides to the current tab
        // instead of each button drawing its own static one. Tracks
        // tabsView's own x plus the current delegate's x within it,
        // minus contentX so it stays put while flicking through tabs
        // (that subtraction is also why the Behaviors below are
        // disabled while tabsView is actually being dragged/flicked --
        // otherwise every scroll-driven x change would itself animate
        // and the indicator would visibly lag behind the scroll).
        Rectangle {
            height: Ayame.Units.borderWidth
            y: parent.height - height
            color: control.colors.highlightColor
            visible: tabsView.currentItem !== null
            x: tabsView.x + (tabsView.currentItem ? tabsView.currentItem.x - tabsView.contentX : 0)
            width: tabsView.currentItem ? tabsView.currentItem.width : 0

            Behavior on x {
                enabled: !tabsView.moving && !tabsView.dragging
                NumberAnimation { duration: Ayame.Units.shortDuration; easing.type: Easing.OutCubic }
            }
            Behavior on width {
                enabled: !tabsView.moving && !tabsView.dragging
                NumberAnimation { duration: Ayame.Units.shortDuration; easing.type: Easing.OutCubic }
            }
        }
    }
}
