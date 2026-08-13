pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Ayame 1.0

// Themed drop-in for QQC2's BusyIndicator, same "wrap the QQC2 type,
// replace its contentItem" approach as every other widgets/*.qml here.
// No existing hand-rolled spinner anywhere in the codebase to match
// (MapView.qml's tile-generation spinner -- the only real call site --
// was left fully unstyled), so this is a fresh design rather than a
// folded-in duplicate: a ring of 8 dots, fading around the ring, the
// whole ring spinning while `running` -- plain QtQuick primitives, no
// image asset or extra Qt module.
QQC2.BusyIndicator {
    id: control

    // Same knob as widgets/Label.qml/widgets/inputs/CheckBox.qml.
    property int colorSet: Theme.view

    readonly property var colors: Theme.paletteFor(control.colorSet)

    readonly property int _dotCount: 8

    implicitWidth: Units.iconSizes.medium
    implicitHeight: Units.iconSizes.medium

    contentItem: Item {
        id: ring
        opacity: control.running ? 1.0 : 0.0

        Repeater {
            model: control._dotCount

            delegate: Rectangle {
                id: dot
                required property int index

                readonly property real _angle: (index / control._dotCount) * 2 * Math.PI
                readonly property real _radius: Math.min(ring.width, ring.height) / 2 - width / 2

                width: Math.max(2, ring.width * 0.14)
                height: width
                radius: width / 2
                color: control.colors.highlightColor
                opacity: 0.25 + 0.75 * (index / control._dotCount)

                x: ring.width / 2 + Math.cos(dot._angle) * dot._radius - width / 2
                y: ring.height / 2 + Math.sin(dot._angle) * dot._radius - height / 2
            }
        }

        RotationAnimation on rotation {
            running: control.running
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: Units.veryLongDuration * 2
        }
    }
}
