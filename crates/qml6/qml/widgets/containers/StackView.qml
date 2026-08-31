pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.StackView {
    id: control

    // No dedicated StyleReader.ControlType for StackView -- falls back to
    // `control` (view colorSet), unlike the old `window` colorSet this
    // file declared. Not a behavior change in practice: `colors` has
    // never been read anywhere in this file (no background Rectangle),
    // same passthrough-only situation as AbstractButton.qml/Control.qml.
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

    // T.StackView's prototype is T.Control, not T.Container -- unlike
    // every other file in this directory, `contentWidth`/`contentHeight`
    // don't exist on it (that's Container's API). Pre-existing bug (both
    // were `undefined` here, same class as Dial.qml's/SplitView.qml's own
    // bugs), never caught before since StackView had never actually been
    // instantiated in a headless run. Fixed to Control's own
    // `implicitContentWidth`/`implicitContentHeight` alongside the
    // color-source migration.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    // Without these, T.StackView still works but every push()/pop()/
    // replace() snaps instantly with no transition. Matches
    // QtQuick.Controls.Basic's own StackView.qml (same durations/easing).
    popEnter: Transition {
        XAnimator { from: (control.mirrored ? -1 : 1) * -control.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
    }

    popExit: Transition {
        XAnimator { from: 0; to: (control.mirrored ? -1 : 1) * control.width; duration: 400; easing.type: Easing.OutCubic }
    }

    pushEnter: Transition {
        XAnimator { from: (control.mirrored ? -1 : 1) * control.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
    }

    pushExit: Transition {
        XAnimator { from: 0; to: (control.mirrored ? -1 : 1) * -control.width; duration: 400; easing.type: Easing.OutCubic }
    }

    replaceEnter: Transition {
        XAnimator { from: (control.mirrored ? -1 : 1) * control.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
    }

    replaceExit: Transition {
        XAnimator { from: 0; to: (control.mirrored ? -1 : 1) * -control.width; duration: 400; easing.type: Easing.OutCubic }
    }
}
