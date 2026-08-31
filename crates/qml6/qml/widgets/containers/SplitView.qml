pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.SplitView {
    id: control

    // No dedicated StyleReader.ControlType for SplitView -- falls back to
    // `control`. `SplitHandle` is a QtQuick.Templates attached type (see
    // Qt's own Basic style SplitView.qml, which spells it `T.SplitHandle`)
    // -- the bare `SplitHandle` this file used before this migration was
    // an unresolved-identifier bug, never caught because SplitView had
    // never actually been instantiated in a headless run before. Fixed
    // alongside the color-source migration since this batch's own
    // verification caught it.
    handle: Rectangle {
        id: handleItem
        implicitWidth: control.orientation === Qt.Horizontal ? 4 : control.width
        implicitHeight: control.orientation === Qt.Horizontal ? control.height : 4

        // Rest-state "subColor" (translucent text color) has no
        // Qt.labs.StyleKit equivalent, same as PageIndicator's dots --
        // kept as a local blend off the live palette.
        readonly property color _subColor: Qt.rgba(control.palette.text.r, control.palette.text.g, control.palette.text.b, 0.3)

        LabsStyleKit.StyleReader {
            id: styleReader
            controlType: LabsStyleKit.StyleReader.Control
            enabled: control.enabled
            hovered: T.SplitHandle.hovered
            pressed: T.SplitHandle.pressed
            palette: control.palette
        }

        color: T.SplitHandle.pressed || T.SplitHandle.hovered ? styleReader.background.color : handleItem._subColor
    }
}
