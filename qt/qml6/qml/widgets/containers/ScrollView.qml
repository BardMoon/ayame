pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

// Themed drop-in for QQC2's ScrollView. Placed at `widgets/` root (like
// Label.qml/Popup.qml), not `widgets/inputs/`: it's chrome wrapping other
// content, not an input control itself.
//
// Both the `T.ScrollBar.vertical`/`.horizontal` attached-property
// qualifiers AND the `Ayame.ScrollBar` instances below are explicitly
// qualified, unlike qqc2-breeze-style's own ScrollView.qml (which can get
// away with a bare `ScrollBar` because every one of its files lives
// flat in a single `org/kde/breeze/` directory -- same-directory QML
// files resolve each other by bare name with no import needed). Ayame's
// own widgets are split across subdirectories
// (`widgets/scroll/ScrollBar.qml` vs. this file in
// `widgets/containers/`), so that same-directory rule doesn't apply here
// -- a bare `ScrollBar` would resolve to nothing usable (confirmed while
// investigating Menu.qml's own cross-directory `ScrollIndicator`
// reference, which needed the same fix). Always use `Ayame.<Type>` for
// any cross-directory reference within this module.
T.ScrollView {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    // widgets/scroll/ScrollBar.qml no longer takes a `colorSet` --
    // migrated (this batch) to read colors straight off its own
    // `control.palette` instead, so there's nothing left to forward here.
    T.ScrollBar.vertical: Ayame.ScrollBar {}

    T.ScrollBar.horizontal: Ayame.ScrollBar {}
}
