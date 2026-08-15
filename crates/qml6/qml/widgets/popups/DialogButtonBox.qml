pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.DialogButtonBox {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    spacing: Ayame.Units.smallSpacing
    padding: Ayame.Units.smallSpacing
    alignment: control.count === 1 ? Qt.AlignRight : undefined

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, (control.count === 1 ? implicitContentWidth * 2 : implicitContentWidth) + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)
    contentWidth: (contentItem as ListView)?.contentWidth

    // Without delegate/contentItem, T.DialogButtonBox (headless) never
    // renders the buttons added to it at all -- same missing-piece shape
    // as ComboBox's missing popup/delegate. Matches
    // QtQuick.Controls.Basic's own DialogButtonBox.qml.
    delegate: Ayame.Button {
        width: control.count === 1 ? control.availableWidth / 2 : undefined
    }

    contentItem: ListView {
        implicitWidth: contentWidth
        model: control.contentModel
        spacing: control.spacing
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapToItem
    }

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.colors.backgroundColor
    }
}
