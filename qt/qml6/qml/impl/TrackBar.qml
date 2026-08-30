import QtQuick
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

// Shared pill-shaped track background for Slider, RangeSlider, and
// ProgressBar's "bar" -- same rounded-rect look (fill + border, fully
// rounded ends), so a thickness/look change only has to happen here
// instead of three near-identical Rectangles. Each caller still owns its
// own x/y/width/height positioning (horizontal vs vertical, centered
// within a taller control, etc.) and whatever fill/stripes sit on top.
Rectangle {
    // Rounded to a whole pixel: Units.smallSpacing * 1.4 is usually
    // fractional, and a fractional thickness/border stroke on a thin
    // rounded-rect renders visibly blurry (same class of issue as
    // RadioButton's centering bug -- subpixel geometry doesn't align to
    // the pixel grid the rasterizer snaps to).
    property real thickness: Math.round(StyleKit.Units.smallSpacing * 1.4)
    property color trackColor: "transparent"
    property color trackBorderColor: "transparent"

    implicitWidth: thickness
    implicitHeight: thickness
    radius: thickness / 2
    color: trackColor
    border.width: StyleKit.Units.borderWidth
    border.color: trackBorderColor
}
