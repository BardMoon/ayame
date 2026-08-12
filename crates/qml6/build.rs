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
                "qml/widgets/AbstractButton.qml",
                "qml/widgets/Action.qml",
                "qml/widgets/ActionGroup.qml",
                "qml/widgets/ApplicationWindow.qml",
                "qml/widgets/BusyIndicator.qml",
                "qml/widgets/Button.qml",
                "qml/widgets/CheckBox.qml",
                "qml/widgets/CheckDelegate.qml",
                "qml/widgets/ComboBox.qml",
                "qml/widgets/Container.qml",
                "qml/widgets/Control.qml",
                "qml/widgets/DelayButton.qml",
                "qml/widgets/Dial.qml",
                "qml/widgets/Dialog.qml",
                "qml/widgets/DialogButtonBox.qml",
                "qml/widgets/Drawer.qml",
                "qml/widgets/Frame.qml",
                "qml/widgets/GroupBox.qml",
                "qml/widgets/ItemDelegate.qml",
                "qml/widgets/Label.qml",
                "qml/widgets/Menu.qml",
                "qml/widgets/MenuItem.qml",
                "qml/widgets/MenuSeparator.qml",
                "qml/widgets/Page.qml",
                "qml/widgets/PageIndicator.qml",
                "qml/widgets/Pane.qml",
                "qml/widgets/Popup.qml",
                "qml/widgets/ProgressBar.qml",
                "qml/widgets/RadioButton.qml",
                "qml/widgets/RadioDelegate.qml",
                "qml/widgets/RangeSlider.qml",
                "qml/widgets/RoundButton.qml",
                "qml/widgets/ScrollBar.qml",
                "qml/widgets/ScrollIndicator.qml",
                "qml/widgets/ScrollView.qml",
                "qml/widgets/Slider.qml",
                "qml/widgets/SpinBox.qml",
                "qml/widgets/SplitView.qml",
                "qml/widgets/StackView.qml",
                "qml/widgets/SwipeDelegate.qml",
                "qml/widgets/SwipeView.qml",
                "qml/widgets/Switch.qml",
                "qml/widgets/SwitchDelegate.qml",
                "qml/widgets/TabBar.qml",
                "qml/widgets/TabButton.qml",
                "qml/widgets/TextArea.qml",
                "qml/widgets/TextField.qml",
                "qml/widgets/ToolBar.qml",
                "qml/widgets/ToolButton.qml",
                "qml/widgets/ToolSeparator.qml",
                "qml/widgets/ToolTip.qml",
                "qml/widgets/Tumbler.qml",
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
