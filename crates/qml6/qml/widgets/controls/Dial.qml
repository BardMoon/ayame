pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

T.Dial {
    id: control

    property int colorSet: StyleKit.Theme.view
    readonly property var colors: StyleKit.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Item {
        implicitWidth: StyleKit.Units.gridUnit * 3.5
        implicitHeight: StyleKit.Units.gridUnit * 3.5

        // Noticeably thicker than TrackBar's bar thickness -- at bar
        // thickness this reads as basically invisible wrapped around a
        // ~gridUnit*3.5 circle instead of a strip. Still rounded to a
        // whole pixel for the same reason TrackBar.qml's thickness is
        // -- a fractional stroke width on a thin arc renders blurry.
        readonly property real ringThickness: Math.round(StyleKit.Units.smallSpacing * 3)

        // qqc2-style-breeze's Dial keeps the handle nearly filling the
        // whole circle, with just a thin groove right at its edge
        // (BreezeDial's grooveThickness is a small fraction of the
        // control size) -- half the ring's own thickness as margin
        // puts the groove astride the knob's edge instead of carving
        // out a big surrounding gap.
        Rectangle {
            anchors.fill: parent
            anchors.margins: parent.ringThickness / 2
            radius: width / 2
            color: control.colors.backgroundColor
            border.width: StyleKit.Units.borderWidth
            border.color: control.hovered ? control.colors.highlightColor : control.colors.borderColor
        }

        // A ProgressBar-like ring wrapped around the dial: a full-sweep
        // track (control.startAngle..endAngle, same look as
        // TrackBar/ProgressBar's plain bar) plus a highlighted arc
        // filled up to the current value, both round-capped.
        // PathAngleArc's 0deg is the 3-o'clock position and increases
        // clockwise, while Dial's angle/startAngle/endAngle are
        // measured from 12 o'clock -- hence the "-90" conversion below.
        Shape {
            id: progressRing
            anchors.fill: parent
            antialiasing: true
            preferredRendererType: Shape.CurveRenderer

            readonly property real _radius: (width - parent.ringThickness) / 2
            // A Shape stroke has no separate fill-inside-border concept
            // like Rectangle does, so the track (which needs a visibly
            // different border vs. fill color, same as TrackBar's plain
            // bar) is drawn as two concentric round-capped arcs: a
            // full-thickness borderColor band, then a narrower
            // backgroundColor band on top -- leaving a borderColor rim
            // showing all the way around, including at the rounded caps.
            readonly property real _trackFillStrokeWidth: Math.max(1, parent.ringThickness - StyleKit.Units.borderWidth * 2)

            ShapePath {
                strokeWidth: parent.ringThickness
                strokeColor: control.colors.borderColor
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: progressRing.width / 2
                    centerY: progressRing.height / 2
                    radiusX: progressRing._radius
                    radiusY: progressRing._radius
                    startAngle: control.startAngle - 90
                    sweepAngle: control.endAngle - control.startAngle
                }
            }

            ShapePath {
                strokeWidth: progressRing._trackFillStrokeWidth
                strokeColor: control.colors.backgroundColor
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: progressRing.width / 2
                    centerY: progressRing.height / 2
                    radiusX: progressRing._radius
                    radiusY: progressRing._radius
                    startAngle: control.startAngle - 90
                    sweepAngle: control.endAngle - control.startAngle
                }
            }

            // Filled portion up to the current value -- flat
            // highlightColor, matching ProgressBar's own fill (which is
            // solid highlightColor for both border and background, so
            // no separate layering is needed here).
            ShapePath {
                strokeWidth: parent.ringThickness
                strokeColor: control.colors.highlightColor
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: progressRing.width / 2
                    centerY: progressRing.height / 2
                    radiusX: progressRing._radius
                    radiusY: progressRing._radius
                    startAngle: control.startAngle - 90
                    sweepAngle: control.angle - control.startAngle
                }
            }
        }
    }

    handle: Rectangle {
        id: handleItem
        x: control.background.x + control.background.width / 2 - width / 2
        y: control.background.y + control.background.height / 2 - height / 2
        width: 10
        height: 10
        radius: 5
        color: control.colors.highlightColor
        transform: [
            Translate {
                y: -control.background.height / 2 + 8
            },
            Rotation {
                angle: control.angle
                origin.x: handleItem.width / 2
                origin.y: handleItem.height / 2
            }
        ]
    }
}
