# How Qt Quick Controls 2 resolves a custom style's import URI

## The rule

When `QT_QUICK_CONTROLS_STYLE` (or `QQuickStyle::setStyle()`, or
`qtquickcontrols2.conf`'s `Style=`) names a **built-in** Qt style
(`Basic`, `Fusion`, `FluentWinUI3`, `Imagine`, `Material`, `Universal`,
`Windows`, `macOS`, `iOS`), Qt imports `QtQuick.Controls.<StyleName>`
-- the `"QtQuick.Controls."` prefix is added automatically.

When it names anything else -- i.e. a **custom** style, which is
whatever `QQuickStylePrivate::isCustomStyle()` returns true for (not in
that built-in list) -- Qt imports the name **exactly as given, with no
prefix at all**. `Ayame` is a custom style, so `QT_QUICK_CONTROLS_STYLE
=Ayame` makes Qt do the equivalent of `import Ayame`, not `import
QtQuick.Controls.Ayame`.

This means a custom style's actual QML module name, and the directory it
lives in on the QML import path, must be exactly the string passed to
`QT_QUICK_CONTROLS_STYLE` -- following the ordinary QML module ⇄
directory convention (dots become path separators) like any other
module, nothing style-specific about it. For Ayame that's a flat
`Ayame/` directory (module `Ayame`) directly on the import path, not
`QtQuick/Controls/Ayame/`.

qqc2-breeze-style follows the same rule with a different (dotted) style
name: `QT_QUICK_CONTROLS_STYLE=org.kde.breeze`, module `org.kde.breeze`,
directory `org/kde/breeze/`. The dots in `org.kde.breeze` aren't a
special "fully-qualified style" scheme distinct from Ayame's -- it's the
exact same "custom style name used verbatim" rule; Breeze's authors just
chose a dotted name.

## Where this is decided in Qt's own source

`qtdeclarative/src/quickcontrols/qtquickcontrols2plugin.cpp`,
`styleUri()` (Qt 6.11.1):

```cpp
QString styleUri()
{
    const QString style = QQuickStyle::name();
    if (!QQuickStylePrivate::isCustomStyle()) {
        // The style set is a built-in style.
        const QString styleName = QQuickStylePrivate::effectiveStyleName(style);
        return QString::fromLatin1("QtQuick.Controls.%1").arg(styleName);
    }

    // This is a custom style, so just use the name as the import uri.
    QString styleName = style;
    if (styleName.startsWith(QLatin1String(":/")))
        styleName.remove(0, 2);
    return styleName;
}
```

`QQuickStylePrivate::isCustomStyle()` (`qquickstyle.cpp`) is `true`
whenever the resolved style name isn't in `builtInStyles()`:

```cpp
QStringList QQuickStylePrivate::builtInStyles()
{
    return {
        QLatin1String("Basic"), QLatin1String("Fusion"),
        QLatin1String("FluentWinUI3"), QLatin1String("Imagine"),
        // + macOS/iOS/Windows depending on platform
        QLatin1String("Material"), QLatin1String("Universal"),
    };
}
```

`registerTypes()` in the same plugin file then calls
`qmlRegisterModuleImport("QtQuick.Controls", ..., registeredStyleUri,
...)`, where `registeredStyleUri` is exactly `styleUri()`'s return value
-- so this is what actually makes `import QtQuick.Controls` pull in the
configured style's own module.

Fetched via `nix build --no-link --print-out-paths
qtdeclarative-everywhere-src-<version>.tar.xz.drv`, extracted, and read
directly -- not from memory/documentation paraphrase, since generic Qt
docs/training-data recall turned out to be wrong about this specific
built-in-vs-custom distinction (see "History" below).

## History: how this got found

Ayame's `build.rs` used to register the QML module as `"Ayame"`. A
prior change (commit `e553611`, "explicit-ayame-namespace") renamed it
to `"QtQuick.Controls.Ayame"`, on the assumption that
`QT_QUICK_CONTROLS_STYLE=Ayame` (a short, non-dotted name) needed the
`"QtQuick.Controls."` prefix to resolve -- a real, working pattern for
Qt's *own* built-in styles, generalized incorrectly to custom ones too.

That assumption went unquestioned through a separate debugging session
(a right-click context menu in the `cettila` app rendering ~5px wide,
eventually traced to Ayame's own `Menu.qml` never binding
`implicitWidth`) and led to renaming the module to
`"QtQuick.Controls.Ayame"` everywhere, on the theory that Ayame wasn't
being recognized as a real QQC2 style at all. It was already working
under the plain `"Ayame"` name before that rename; the rename broke it
(`module "Ayame" is not installed` at runtime, since `QT_QUICK_CONTROLS
_STYLE=Ayame` still expects a module literally named `Ayame`). Reading
Qt's own `styleUri()` (above) confirmed why, and the module name was
reverted to `"Ayame"`.

## Practical checklist for this project

- `crates/qml6/build.rs`: `QmlModule::new("Ayame")` (not
  `"QtQuick.Controls.Ayame"`).
- `nix/pkgs/ayame.nix`: install into `$out/lib/qt-6/qml/Ayame/` (not
  nested under `QtQuick/Controls/`).
- Any QML file that needs Ayame's own `Theme`/`Units`/settings types:
  `import Ayame 1.0 as Ayame` (not `import QtQuick.Controls.Ayame ...`).
- `nix/dev.nix` / `nix/pkgs/cettila.nix`: `QT_QUICK_CONTROLS_STYLE`
  stays `"Ayame"` (the short custom-style name, used verbatim -- no
  prefix needed or wanted).
