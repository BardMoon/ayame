import QtQuick
import QtQuick.Shapes
import Ayame 1.0 as Ayame

// Two independent visual cues layered on top of a control's background,
// both keyed off Ayame.Units.borderWidth/cornerRadius so they line up with
// the plain border drawn by the control itself:
//  - `animating`: a bright arc chases around the border in an infinite
//    loop (the ConicalGradient-filled ring Shape below) -- e.g. Button.qml
//    drives this from `highlighted`.
//  - `active`: a solid border in `ringColor` fades in/out (via
//    `fadeDuration`, 0 -- i.e. an instant snap -- whenever
//    `Ayame.Units.animationsEnabled` is off, same as every other duration
//    constant on Units) -- e.g. Button.qml drives this from `activeFocus`,
//    replacing the old "activeFocus instantly swaps the border to
//    highlightColor" treatment with a soft fade.
// Anchor this to `parent.fill`; both cues are independent and can be
// active at once.
Item {
    id: root

    property bool animating: false
    property bool active: false
    property color ringColor: "transparent"
    property real cornerRadius: Ayame.Units.cornerRadius
    property real ringThickness: Ayame.Units.borderWidth
    property int duration: Ayame.Units.veryLongDuration * 4
    property int fadeDuration: Ayame.Units.shortDuration

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: "transparent"
        border.width: root.ringThickness
        border.color: root.ringColor
        opacity: root.active ? 1.0 : 0.0

        Behavior on opacity {
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
