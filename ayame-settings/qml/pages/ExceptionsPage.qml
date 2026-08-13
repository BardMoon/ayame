import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.ayame.settings

QQC2.Page {
    id: root

    required property AyameSettingsObject settings

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        QQC2.Label {
            text: "Window Specific Overrides / Exceptions"
            font.pixelSize: 18
            font.bold: true
        }

        QQC2.Label {
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

            delegate: QQC2.ItemDelegate {
                width: ListView.view.width
                text: model.ruleName + " [" + model.matchStr + "]"
            }
        }

        RowLayout {
            QQC2.Button { text: "Add Exception Rule" }
            QQC2.Button { text: "Remove Selected" }
        }
    }
}
