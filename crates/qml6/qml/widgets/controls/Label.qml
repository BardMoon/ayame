pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

// Themed drop-in for QQC2's Label. Every call site across the app used to
// hand-roll `color: root.colors.textColor` (plus ad-hoc `opacity: 0.5`/
// `0.7` for de-emphasized text, or a fixed hex color for errors) on a bare
// T.Label -- this folds those repeated patterns into a small `type`
// variant so call sites only need to say what they mean.
T.Label {
    id: control

    // plain | secondary | disabled | positive | negative | neutral
    property string type: "plain"

    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Label
        enabled: control.enabled
        palette: control.palette
    }

    // Semantic colors (positive/negative/neutral) have no
    // Qt.labs.StyleKit equivalent -- no QPalette role and no ControlStyle
    // property for them -- so they stay fixed hex constants, same values
    // the old StyleKit.Theme singleton used.
    readonly property var _semanticColors: ({
            positive: "#27ae60",
            negative: "#da4453",
            neutral: "#f67400"
        })

    readonly property var _semanticOpacities: ({
            secondary: 0.7,
            disabled: 0.5
        })

    color: control._semanticColors[control.type] ?? styleReader.text.color
    opacity: control._semanticOpacities[control.type] ?? 1.0
}
