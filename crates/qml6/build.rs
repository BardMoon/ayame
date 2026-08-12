use cxx_qt_build::{CxxQtBuilder, QmlFile, QmlModule};
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=qml");
    println!("cargo:rerun-if-changed=cpp");
    println!("cargo:rerun-if-changed=src/cxxqt_object.rs");

    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let cpp_dir = Path::new(&manifest_dir).join("cpp");

    CxxQtBuilder::new_qml_module(
        QmlModule::new("la.cettila.Ayame")
            .qml_files([
                QmlFile::from("qml/theme/Units.qml").singleton(true),
                QmlFile::from("qml/theme/Theme.qml").singleton(true),
            ])
            .qml_files([
                "qml/widgets/buttons/AbstractButton.qml",
                "qml/widgets/buttons/Button.qml",
                "qml/widgets/buttons/DelayButton.qml",
                "qml/widgets/buttons/RadioButton.qml",
                "qml/widgets/buttons/RoundButton.qml",
                "qml/widgets/buttons/TabButton.qml",
                "qml/widgets/buttons/ToolButton.qml",
                "qml/widgets/containers/ApplicationWindow.qml",
                "qml/widgets/containers/Container.qml",
                "qml/widgets/containers/Frame.qml",
                "qml/widgets/containers/GroupBox.qml",
                "qml/widgets/containers/Page.qml",
                "qml/widgets/containers/Pane.qml",
                "qml/widgets/containers/ScrollView.qml",
                "qml/widgets/containers/SplitView.qml",
                "qml/widgets/containers/StackView.qml",
                "qml/widgets/containers/SwipeView.qml",
                "qml/widgets/containers/TabBar.qml",
                "qml/widgets/containers/ToolBar.qml",
                "qml/widgets/controls/BusyIndicator.qml",
                "qml/widgets/controls/CheckBox.qml",
                "qml/widgets/controls/ComboBox.qml",
                "qml/widgets/controls/Control.qml",
                "qml/widgets/controls/Dial.qml",
                "qml/widgets/controls/Label.qml",
                "qml/widgets/controls/PageIndicator.qml",
                "qml/widgets/controls/ProgressBar.qml",
                "qml/widgets/controls/RangeSlider.qml",
                "qml/widgets/controls/Slider.qml",
                "qml/widgets/controls/SpinBox.qml",
                "qml/widgets/controls/Switch.qml",
                "qml/widgets/controls/Tumbler.qml",
                "qml/widgets/delegates/CheckDelegate.qml",
                "qml/widgets/delegates/ItemDelegate.qml",
                "qml/widgets/delegates/RadioDelegate.qml",
                "qml/widgets/delegates/SwipeDelegate.qml",
                "qml/widgets/delegates/SwitchDelegate.qml",
                "qml/widgets/inputs/TextArea.qml",
                "qml/widgets/inputs/TextField.qml",
                "qml/widgets/menus/Action.qml",
                "qml/widgets/menus/ActionGroup.qml",
                "qml/widgets/menus/Menu.qml",
                "qml/widgets/menus/MenuItem.qml",
                "qml/widgets/menus/MenuSeparator.qml",
                "qml/widgets/popups/Dialog.qml",
                "qml/widgets/popups/DialogButtonBox.qml",
                "qml/widgets/popups/Drawer.qml",
                "qml/widgets/popups/Popup.qml",
                "qml/widgets/popups/ToolTip.qml",
                "qml/widgets/scroll/ScrollBar.qml",
                "qml/widgets/scroll/ScrollIndicator.qml",
                "qml/widgets/scroll/ToolSeparator.qml",
            ]),
    )
    .files(["src/cxxqt_object.rs"])
    .cpp_file(cpp_dir.join("style_query.h"))
    .cpp_file(cpp_dir.join("style_query.cpp"))
    .cpp_file(cpp_dir.join("theme_palette.h"))
    .cpp_file(cpp_dir.join("theme_palette.cpp"))
    .cpp_file(cpp_dir.join("font_query.h"))
    .cpp_file(cpp_dir.join("font_query.cpp"))
    .qt_module("Quick")
    .qt_module("QuickControls2")
    .build()
    .export();
}
