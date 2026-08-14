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
        border.width: Ayame.Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.2)
    }
}
