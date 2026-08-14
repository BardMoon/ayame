pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

// Themed drop-in for QQC2's ScrollView. Placed at `widgets/` root (like
// Label.qml/Popup.qml), not `widgets/inputs/`: it's chrome wrapping other
// content, not an input control itself.
//
// UNLIKE the other widget files here (which qualify every base-type/enum
// reference as `T.<Type>`), the composed `ScrollBar.vertical`/
// `.horizontal` below stay BARE -- both the attached-property qualifier
// and the child instances. Bare `ScrollBar` inside this same QML module
// resolves directly to this module's own themed
// `widgets/scroll/ScrollBar.qml` (same-module sibling-type resolution,
// no import needed), which is what actually makes the composed
// scrollbars themed rather than an unstyled `T.ScrollBar`. Matches
// qqc2-breeze-style's own ScrollView.qml (confirmed on disk), which uses
// this exact same bare-`ScrollBar` idiom for the identical reason.
T.ScrollView {
    id: control

    // Same knob as widgets/Label.qml/widgets/inputs/CheckBox.qml.
    property int colorSet: Ayame.Theme.view

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    T.ScrollBar.vertical: Ayame.ScrollBar {
        colorSet: control.colorSet
    }

    T.ScrollBar.horizontal: Ayame.ScrollBar {
        colorSet: control.colorSet
    }
}
