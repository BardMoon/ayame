pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.StackView {
    id: control

    property int colorSet: Ayame.Theme.window
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

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
