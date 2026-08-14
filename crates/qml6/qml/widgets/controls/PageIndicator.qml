pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.PageIndicator {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    padding: Ayame.Units.smallSpacing
    spacing: Ayame.Units.smallSpacing

    delegate: Rectangle {
        required property int index

        implicitWidth: 8
        implicitHeight: 8
        radius: 4
        color: index === control.currentIndex ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }

    // T.PageIndicator has no built-in layout for its delegates -- without
    // this, `delegate` is never actually instantiated `count` times
    // anywhere. Same Row+Repeater-over-count idiom as
    // QtQuick.Controls.Basic's own PageIndicator.qml.
    contentItem: Row {
        spacing: control.spacing

        Repeater {
            model: control.count
            delegate: control.delegate
        }
    }
}
