pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.ProgressBar {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    // Pinned to the shared track thickness (not derived via the usual
    // implicitContentHeight + padding formula) -- same reasoning as
    // Slider: the fill below is the same size as the track, so the
    // control itself should be too.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: track.thickness

    background: Ayame.TrackBar {
        id: track
        implicitWidth: Ayame.Units.gridUnit * 8
        trackColor: control.colors.backgroundColor
        trackBorderColor: control.colors.borderColor
    }

    contentItem: Item {
        implicitWidth: Ayame.Units.gridUnit * 8
        implicitHeight: track.thickness
        clip: true

        // Same size as the track (not inset).
        Rectangle {
            visible: !control.indeterminate
            width: control.position * parent.width
            height: parent.height
            radius: track.radius
            color: control.colors.highlightColor
            border.width: Ayame.Units.borderWidth
            border.color: control.colors.highlightColor
        }

        // control.position isn't meaningful while indeterminate -- a
        // repeating stripe pattern scrolling left-to-right forever
        // instead. stripesRow is laid out one repeat unit (two stripes)
        // wider than it needs to be and cycled by exactly one repeat
        // unit, so the loop point is seamless.
        // Inset by the border width, unlike the determinate fill above --
        // the stripes are a separate repeating pattern next to the
        // track's own border rather than a bordered shape coincident
        // with it, so left uninset they'd visibly draw over it.
        Item {
            id: indeterminateLayer
            x: Ayame.Units.borderWidth
            y: Ayame.Units.borderWidth
            width: parent.width - Ayame.Units.borderWidth * 2
            height: parent.height - Ayame.Units.borderWidth * 2
            visible: control.indeterminate

            readonly property real stripeWidth: Ayame.Units.smallSpacing * 6
            readonly property real gapWidth: Ayame.Units.smallSpacing * 4
            readonly property real repeatWidth: stripeWidth + gapWidth

            Row {
                id: stripesRow
                height: parent.height

                Repeater {
                    model: Math.ceil(indeterminateLayer.width / indeterminateLayer.gapWidth) + 4

                    Rectangle {
                        required property int index

                        width: index % 2 === 0 ? indeterminateLayer.stripeWidth : indeterminateLayer.gapWidth
                        height: parent.height
                        radius: track.radius
                        color: index % 2 === 0 ? control.colors.borderColor : "transparent"
                    }
                }

                NumberAnimation on x {
                    running: control.indeterminate && Ayame.Units.animationsEnabled
                    loops: Animation.Infinite
                    from: -indeterminateLayer.repeatWidth
                    to: 0
                    duration: Ayame.Units.veryLongDuration * 2
                }
            }
        }
    }
}
