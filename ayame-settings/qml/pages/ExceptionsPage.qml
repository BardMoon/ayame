import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.ayame.settings

Page {
    id: root

    required property AyameSettingsObject settings

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Label {
            text: "Window Specific Overrides / Exceptions"
            font.pixelSize: 18
            font.bold: true
        }

        Label {
            text: "Configure custom window decoration rules for specific applications (e.g. matching window class or title)."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ListModel {
                ListElement { ruleName: "Example Rule (No Titlebar for Alacritty)"; matchStr: "alacritty" }
            }

            delegate: ItemDelegate {
                width: ListView.view.width
                text: model.ruleName + " [" + model.matchStr + "]"
            }
        }

        RowLayout {
            Button { text: "Add Exception Rule" }
            Button { text: "Remove Selected" }
        }
    }
}
