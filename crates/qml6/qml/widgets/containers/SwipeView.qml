pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.SwipeView {
    id: control

    property int colorSet: Ayame.Theme.window
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    // Without this, T.SwipeView (headless) has nothing to actually flick
    // between pages with -- same missing-piece shape as ComboBox's missing
    // popup/delegate. Matches QtQuick.Controls.Basic's own SwipeView.qml.
    contentItem: ListView {
        model: control.contentModel
        interactive: control.interactive
        currentIndex: control.currentIndex
        focus: control.focus

        spacing: control.spacing
        orientation: control.orientation
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds

        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: 0
        preferredHighlightEnd: 0
        highlightMoveDuration: 250
        maximumFlickVelocity: 4 * (control.orientation === Qt.Horizontal ? width : height)
    }
}
