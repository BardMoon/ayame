pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import Ayame 1.0 as Ayame

// Themed drop-in for QQC2's Label. Every call site across the app used to
// hand-roll `color: root.colors.textColor` (plus ad-hoc `opacity: 0.5`/
// `0.7` for de-emphasized text, or `Ayame.Theme.negativeTextColor` for errors)
// on a bare QQC2.Label -- this folds those repeated patterns into a small
// `type` variant so call sites only need to say what they mean.
QQC2.Label {
    id: control

    // plain | secondary | disabled | positive | negative | neutral
    property string type: "plain"

    // Which Ayame.Theme.paletteFor() color set this label's default text color
    // is drawn from. Defaults to `view` since that's what nearly every
    // call site across the app already used; header/statusbar/tooltip
    // contexts override it, same as every other themed widget here.
    property int colorSet: Ayame.Theme.view

    readonly property var _colors: Ayame.Theme.paletteFor(control.colorSet)

    readonly property var _semanticColors: ({
            positive: control._colors.positiveTextColor,
            negative: control._colors.negativeTextColor,
            neutral: control._colors.neutralTextColor
        })

    readonly property var _semanticOpacities: ({
            secondary: 0.7,
            disabled: 0.5
        })

    color: control._semanticColors[control.type] ?? control._colors.textColor
    opacity: control._semanticOpacities[control.type] ?? 1.0
}
