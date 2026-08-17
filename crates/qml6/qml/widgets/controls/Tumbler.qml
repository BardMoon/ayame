pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.Tumbler {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    readonly property real __delegateHeight: availableHeight / visibleItemCount

    // Without this, T.Tumbler (headless) has no actual scrolling view to
    // render its columns into -- same missing-piece shape as ComboBox's
    // missing popup/delegate. Matches QtQuick.Controls.Basic's own
    // Tumbler.qml (TumblerView + Path wiring).
    // contentItem: TumblerView {
    //     implicitWidth: StyleKit.Units.gridUnit * 3
    //     implicitHeight: StyleKit.Units.gridUnit * 1.6 * control.visibleItemCount
    //     model: control.model
    //     delegate: control.delegate
    //     path: Path {
    //         startX: control.contentItem.width / 2
    //         startY: -control.__delegateHeight / 2

    //         PathLine {
    //             x: control.contentItem.width / 2
    //             y: (control.visibleItemCount + 1) * control.__delegateHeight - control.__delegateHeight / 2
    //         }
    //     }
    // }

    background: Rectangle {
        radius: StyleKit.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: StyleKit.Units.borderWidth
        border.color: control.colors.borderColor
    }

    delegate: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: modelData
        font: control.font
        color: control.colors.textColor
        opacity: 0.4 + (1.0 - Math.abs(Tumbler.displacement) / (control.visibleItemCount / 2)) * 0.6
    }
}
