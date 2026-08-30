pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.SwipeView {
    id: control

    // Same passthrough-only situation as StackView.qml right above it in
    // this migration -- `colors` has never been read anywhere in this
    // file either (the ListView contentItem below has no color bindings).
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        palette: control.palette
    }

    readonly property var colors: ({
        backgroundColor: styleReader.background.color,
        borderColor: styleReader.background.border.color,
        textColor: styleReader.text.color,
        highlightColor: control.palette.highlight,
        highlightedTextColor: control.palette.highlightedText
    })

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
