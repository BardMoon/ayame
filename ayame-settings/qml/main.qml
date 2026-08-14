import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.ayame.settings
import "pages"

QQC2.ApplicationWindow {
    id: window
    width: 760
    height: 540
    visible: true
    title: "Ayame Settings"

    AyameSettingsObject {
        id: settingsObj
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar Navigation
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 180
            color: "#1e1e24"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                QQC2.Label {
                    text: "Ayame Style"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 12
                    Layout.bottomMargin: 16
                }

                QQC2.ToolButton {
                    text: "General"
                    Layout.fillWidth: true
                    highlighted: stackLayout.currentIndex === 0
                    onClicked: stackLayout.currentIndex = 0
                }

                QQC2.ToolButton {
                    text: "Decoration"
                    Layout.fillWidth: true
                    highlighted: stackLayout.currentIndex === 1
                    onClicked: stackLayout.currentIndex = 1
                }

                QQC2.ToolButton {
                    text: "Appearance"
                    Layout.fillWidth: true
                    highlighted: stackLayout.currentIndex === 2
                    onClicked: stackLayout.currentIndex = 2
                }

                QQC2.ToolButton {
                    text: "Exceptions"
                    Layout.fillWidth: true
                    highlighted: stackLayout.currentIndex === 3
                    onClicked: stackLayout.currentIndex = 3
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Content Area & Action Buttons
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            StackLayout {
                id: stackLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                GeneralPage {
                    settings: settingsObj
                }

                DecorationPage {
                    settings: settingsObj
                }

                AppearancePage {}

                ExceptionsPage {
                    settings: settingsObj
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#333333"
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 12
                spacing: 8

                QQC2.Button {
                    text: "Defaults"
                    onClicked: settingsObj.reset_defaults()
                }

                Item { Layout.fillWidth: true }

                QQC2.Button {
                    text: "Reset"
                    onClicked: settingsObj.load()
                }

                QQC2.Button {
                    text: "Apply"
                    highlighted: true
                    onClicked: settingsObj.save()
                }
            }
        }
    }
}
