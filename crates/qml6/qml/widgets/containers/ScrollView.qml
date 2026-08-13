pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import Ayame 1.0 as Ayame

// Themed drop-in for QQC2's ScrollView. Placed at `widgets/` root (like
// Label.qml/Popup.qml), not `widgets/inputs/`: it's chrome wrapping other
// content, not an input control itself.
//
// UNLIKE the other wrapper files here (Button.qml/CheckBox.qml/Label.qml/
// Popup.qml/ScrollBar.qml/Slider.qml), this one roots itself with the
// QUALIFIED `QQC2.ScrollView` rather than the usual "bare self-name"
// trick -- it needs to assign `QQC2.ScrollBar.vertical`/`.horizontal` to
// instances of this SAME module's own themed `ScrollBar` (bare
// `ScrollBar` reference, resolved via the unqualified `la.cettila.Origami`
// import below). Importing `QtQuick.Controls` unqualified too (as the
// bare self-name trick requires) would make that `ScrollBar` reference
// ambiguous between QQC2's and this module's own -- qualifying the root
// type instead sidesteps the question entirely, since only
// `la.cettila.Origami` provides the unqualified `ScrollBar` name in this
// file.
QQC2.ScrollView {
    id: control

    // Same knob as widgets/Label.qml/widgets/inputs/CheckBox.qml.
    property int colorSet: Ayame.Theme.view

    QQC2.ScrollBar.vertical: ScrollBar {
        colorSet: control.colorSet
    }

    QQC2.ScrollBar.horizontal: ScrollBar {
        colorSet: control.colorSet
    }
}
