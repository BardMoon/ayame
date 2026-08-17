import QtQuick
import QtQuick.Shapes
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

// Two independent visual cues layered on top of a control's background,
// both keyed off StyleKit.Units.borderWidth/cornerRadius so they line up with
// the plain border drawn by the control itself:
//  - `animating`: a bright arc chases around the border in an infinite
//    loop (the ConicalGradient-filled ring Shape below) -- e.g. Button.qml
//    drives this from `highlighted`.
//  - `active`: a solid border in `ringColor` fades in (via `fadeDuration`,
//    0 -- i.e. an instant snap -- whenever `StyleKit.Units.animationsEnabled`
//    is off, same as every other duration constant on Units), then
//    keeps breathing between `pulseMinOpacity` and full opacity for as
//    long as `active` stays true, and fades back out on deactivation --
//    e.g. Button.qml drives this from `activeFocus`, replacing the old
//    "activeFocus instantly swaps the border to highlightColor"
//    treatment with a soft fade plus a continuous pulse.
// Anchor this to `parent.fill`; both cues are independent and can be
// active at once.
Item {
    id: root

    property bool animating: false
    property bool active: false
    property color ringColor: "transparent"
    property real cornerRadius: StyleKit.Units.cornerRadius
    property real ringThickness: StyleKit.Units.borderWidth
    property int duration: StyleKit.Units.veryLongDuration * 4
    property int fadeDuration: StyleKit.Units.shortDuration
    property int pulseDuration: StyleKit.Units.veryLongDuration
    property real pulseMinOpacity: 0.35

    // Driven by pulseAnimation below while `active`: its first leg is
    // the fade-in (from whatever it was frozen at on the previous
    // deactivation, normally 0), then it keeps breathing between
    // pulseMinOpacity and 1.0. Kept separate from the Rectangle's own
    // `opacity` so the fade-out Behavior below -- which must react to
    // every opacity change -- doesn't also intercept and re-smooth
    // each pulse tick.
    property real pulsePhase: 0.0

    SequentialAnimation {
        id: pulseAnimation
        running: root.active && StyleKit.Units.animationsEnabled
        loops: Animation.Infinite
        NumberAnimation { target: root; property: "pulsePhase"; to: 1.0; duration: root.fadeDuration; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "pulsePhase"; to: root.pulseMinOpacity; duration: root.pulseDuration; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "pulsePhase"; to: 1.0; duration: root.pulseDuration; easing.type: Easing.InOutSine }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: "transparent"
        border.width: root.ringThickness
        border.color: root.ringColor
        opacity: root.active ? (StyleKit.Units.animationsEnabled ? root.pulsePhase : 1.0) : 0.0

        Behavior on opacity {
            enabled: !root.active
            NumberAnimation { duration: root.fadeDuration; easing.type: Easing.OutCubic }
        }
    }

    Shape {
        id: ring
        anchors.fill: parent
        visible: root.animating
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillRule: ShapePath.OddEvenFill
            strokeColor: "transparent"
            fillColor: "transparent"
            fillGradient: ConicalGradient {
                id: ringGradient
                centerX: ring.width / 2
                centerY: ring.height / 2

                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.6; color: "transparent" }
                GradientStop { position: 0.85; color: root.ringColor }
                GradientStop { position: 1.0; color: "transparent" }
            }

            PathRectangle {
                x: 0
                y: 0
                width: ring.width
                height: ring.height
                radius: root.cornerRadius
            }
            PathRectangle {
                x: root.ringThickness
                y: root.ringThickness
                width: ring.width - root.ringThickness * 2
                height: ring.height - root.ringThickness * 2
                radius: Math.max(0, root.cornerRadius - root.ringThickness)
            }
        }

        NumberAnimation {
            target: ringGradient
            property: "angle"
            running: root.animating
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: root.duration
        }
    }
}
