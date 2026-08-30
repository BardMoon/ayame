import QtQuick
import QtQuick.Templates as T

// Minimal reimplementation of Qt Quick Controls' own private IconLabel
// (QtQuick.Controls.impl), which isn't importable outside Qt's own style
// modules. Only covers what this module's widgets actually need: an
// optional icon Image beside/above/below optional text, or either alone,
// following T.AbstractButton's `display` enum contract. No icon.color
// recolor tinting -- would need QtQuick.Effects (MultiEffect) wired into
// build.rs, nothing in this module needs that yet.
Item {
    id: root

    property url iconSource
    property real iconWidth: 0
    property real iconHeight: 0
    property string text
    property font font
    property color color
    property int display: T.AbstractButton.TextBesideIcon
    property int spacing: 0
    property bool mirrored: false
    property int elide: Text.ElideNone
    property real leftPadding: 0
    property real rightPadding: 0

    // true centers the icon+text group in this Item (Button/ToolButton/
    // RoundButton/TabButton); false left-aligns it, vertically centered
    // (ItemDelegate and friends, which already reserve left/rightPadding
    // above for their own checkbox/radio/switch indicator).
    property bool centered: true

    readonly property bool __showIcon: root.iconSource.toString().length > 0 && root.display !== T.AbstractButton.TextOnly
    readonly property bool __showText: root.text.length > 0 && root.display !== T.AbstractButton.IconOnly
    readonly property bool __stacked: root.display === T.AbstractButton.TextUnderIcon

    implicitWidth: root.__stacked ? columnGroup.implicitWidth : rowGroup.implicitWidth
    implicitHeight: root.__stacked ? columnGroup.implicitHeight : rowGroup.implicitHeight

    Row {
        id: rowGroup
        visible: !root.__stacked
        spacing: root.spacing
        layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: root.centered ? parent.horizontalCenter : undefined
        anchors.left: root.centered ? undefined : parent.left
        anchors.leftMargin: root.centered ? 0 : root.leftPadding
        anchors.right: root.centered ? undefined : parent.right
        anchors.rightMargin: root.centered ? 0 : root.rightPadding

        Image {
            visible: root.__showIcon
            anchors.verticalCenter: parent.verticalCenter
            source: root.iconSource
            sourceSize.width: root.iconWidth
            sourceSize.height: root.iconHeight
            width: root.iconWidth
            height: root.iconHeight
            fillMode: Image.PreserveAspectFit
        }

        Text {
            visible: root.__showText
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font: root.font
            color: root.color
            elide: root.elide
        }
    }

    Column {
        id: columnGroup
        visible: root.__stacked
        spacing: root.spacing
        anchors.centerIn: parent

        Image {
            visible: root.__showIcon
            anchors.horizontalCenter: parent.horizontalCenter
            source: root.iconSource
            sourceSize.width: root.iconWidth
            sourceSize.height: root.iconHeight
            width: root.iconWidth
            height: root.iconHeight
            fillMode: Image.PreserveAspectFit
        }

        Text {
            visible: root.__showText
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.text
            font: root.font
            color: root.color
            elide: root.elide
        }
    }
}
