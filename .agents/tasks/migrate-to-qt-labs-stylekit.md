# Migrate Ayame onto the real Qt.labs.StyleKit

Full design rationale: see `/home/tefla/.claude/plans/delegated-rolling-crown.md`
(plan-mode output from the session that designed this — read it before
starting, it has the full research writeup). Companion task:
`origami-frameworks/.agents/tasks/migrate-to-qt-labs-stylekit.md` (Origami's
custom widgets side; depends on Phase 0 here landing first).

## Why

This session built a hand-rolled `StyleKit` QML module
(`crates/stylekit`, `Theme`/`Units` singleton) to fix a data-sharing bug
between Ayame and Origami. That's a bespoke, Ayame-specific stand-in for
something Qt actually ships for real: `Qt.labs.StyleKit` (Technology
Preview, Qt 6.11) — confirmed present in this project's actual Qt install
(`/nix/store/.../qtdeclarative-6.11.1/lib/qt-6/qml/Qt/labs/StyleKit/`,
Qt's own reference `Button.qml`/`CheckBox.qml`/etc. read directly during
research). It provides `Style`/`ControlStyle`/`CustomControl`/
`StyleReader` — a real declarative styling system, including
`CustomControl` for styling non-built-in control types, which is the
actual fix for the original problem this whole project's theming work
started from (QQC2's per-style-directory mechanism can't style custom
component names — see `docs/qqc2-custom-style-resolution.md`).

Decision (confirmed with the user): keep Ayame's existing
`crates/qml6/qml/widgets/**` files as the real QQC2 style delegates
(`QT_QUICK_CONTROLS_STYLE=Ayame` unchanged) with their existing
hand-painted structure (`HighlightRing`, `IconLabel`, bespoke `Rectangle`
backgrounds) — only swap their color/metric *data source* from our
`StyleKit.Theme`/`Units` crate to a real `Qt.labs.StyleKit` `Style`
definition via `StyleReader`. Do NOT adopt Qt's own reference
implementation files wholesale (they use `Qt.labs.StyleKit.impl` helper
components like `BackgroundDelegate` that Ayame doesn't need to depend on
for this).

## Biggest open risk — RESOLVED empirically in Phase 1 (2026-08-17)

Ayame's current `Theme.qml` derives every color live from `SystemPalette`
(reflecting the user's chosen accent/preset via `ayame-colors` +
`ThemeSettings`) — no fixed palette of its own. Qt's `Theme` QML type docs
only show fixed hex-coded colors per named theme in their example; no
documented example of binding to a live `SystemPalette`. `Theme`
properties are ordinary QML properties so a live binding is very likely
possible, but unproven. If Phase 1 shows `Theme`'s light/dark switching
genuinely can't track a live palette, fall back to binding `AyameStyle`'s
top-level (non-themed) properties directly to `SystemPalette` and skip
Qt's `Theme`/light-dark mechanism entirely — Ayame doesn't need it since
it already gets light/dark for free from whatever `QPalette` is active.

**Answer: the fallback was the right call, skip `Theme`/light-dark entirely.**
`Style` (`BaseStyle`) exposes its own readonly, live-resolved `palette`
property (a `QQuickPalette`, same reactive type `SystemPalette` produces)
independent of `light`/`dark`/`themeName`. `AyameStyle.qml` binds straight
to `root.palette.<role>` (`base`, `text`, `highlight`, ...) — same role
names as `SystemPalette`, same math as the old `Theme.paletteFor()` for
the derived alpha-blended colors (sub/disabled/hover/pressed/border).
Confirmed working end-to-end via the Phase 1 verification steps below
(headless run loaded and reached the Qt event loop with zero QML
warnings). No `Theme{}`/`light`/`dark` component needed at all.

**...but this only covers a *fresh load*, not a *running* app — a second,
more serious problem surfaced afterward (2026-08-17, during Phase 2's
buttons batch, reported by the user testing the real app): `Style.palette`
and `Control.palette` both update live (re-verified empirically, see
below), but `StyleReader`'s *resolved* output
(`styleReader.text.color`/`.background.color`/etc — what every migrated
widget actually reads) does **not** reliably re-resolve for an
already-instantiated widget when the underlying palette or `Style`
changes. Confirmed three ways, each isolating the previous one's possible
explanation:
1. A live `Button` instance's `contentItem.color`
   (`styleReader.text.color`) stayed frozen at its startup value across
   two full `theme.set_mode()` calls over 1200ms, even though
   `debugButton.palette.text` (the control's own inherited palette, read
   at the same moments) correctly showed each new value.
2. Tried the officially-documented reactive mechanism instead of direct
   `root.palette.*` binding: gave `AyameStyle` `light`/`dark: Component {
   Theme { button: ControlStyle { ... } } }` (both pointing at the same
   Component, colors still ultimately from `root.palette`) and a
   `themeName` toggle, on the theory that swapping in a *new* `Theme`
   object (`Style.theme`/`themeChanged`) might be what `StyleReader`
   actually listens for, unlike a plain property mutation on the Style's
   own ControlStyle slots. Toggling `themeName` between two names DID
   force a correct re-resolve the *first* time either name was newly
   entered, but reusing a previously-used name did not — six alternating
   pokes traced a value that was consistently exactly one full toggle
   cycle stale, never catching up even after 2000ms+ of settling time.
   Read as: `Theme` instances are likely cached/pooled per `themeName`,
   and reusing a pooled instance doesn't force a fresh resolve either.
3. A *freshly created* `Button` (via `Qt.createComponent().createObject()`
   right after a theme switch) showed a *different* color than the frozen
   long-lived instance — ruling out "nothing in the whole app ever
   updates" — but still not the *current* value, one step stale (same
   pattern as #2).

No reliable QML-level workaround found. Verdict: `Qt.labs.StyleKit`'s
`StyleReader`, in this Qt 6.11 Technology Preview build, cannot be trusted
to keep already-rendered widgets visually in sync with runtime style/theme
changes — neither via direct property mutation nor via the officially
documented `themeName`/`Theme` swap mechanism.

**Decision (2026-08-17, confirmed with the user): drop live preview as a
product requirement instead of reverting the migration.** Ayame Settings'
Appearance page no longer applies changes immediately as you interact with
controls — every field only updates that page's own buffered property now;
`theme.set_mode()`/`set_accent_color()`/`fontSettings.set_family()`/
`set_point_size()`/`StyleKit.Units.set*Option()`/`setAnimationsEnabled()`/
`setUiScale()` (all of which apply live immediately, confirmed from their
Rust implementations in `crates/qml6/src/cxxqt_object.rs` — `set_mode`
calls `apply_theme()` → `cettila_apply_theme_palette()` →
`QGuiApplication::setPalette()`, `set_family`/`set_point_size` call
`apply_ui_font()`, the `StyleKit.Units` ones mutate the live singleton
directly) now only run once, batched, from `commit()` (Save) —
`ayame-settings/qml/pages/AppearancePage.qml`, see its class doc comment
for the full new model. `cancel()`/`resetToDefaults()` (Cancel/Defaults)
no longer touch the singletons at all — nothing was ever live-applied to
undo. Chosen over reverting because: (a) the *original* problem this
whole `StyleKit`/`Qt.labs.StyleKit` thread started from (Origami's custom
widgets needing a non-hacky way to read Ayame's colors, and QQC2's
per-style-directory mechanism structurally being unable to style custom
component names) is unaffected by this finding — `CustomControl` still
works fine for that, since it doesn't depend on *runtime* re-resolution,
only correct-at-load resolution; (b) a full revert would throw away
Phase 0-1's confirmed-working design; (c) restart-to-apply is a common,
acceptable pattern for appearance settings elsewhere too.
Consequence for the rest of this migration: Phase 2 is unblocked again —
`StyleReader` resolving correctly *once*, at widget-creation time, is now
all that's required, which was already confirmed working since Phase 1.

## Steps

- [x] **Phase 0 — Design `AyameStyle`.** Landed at
      `crates/qml6/qml/style/AyameStyle.qml` (same crate/module as the
      widgets, not a separate crate — added as one more entry in
      `crates/qml6/build.rs`'s existing `widget_files` list feeding
      `QmlModule::new("Ayame")`; no build.rs wrinkles from doing it this
      way). Scope actually done, vs. deferred to Phase 2:
  - **Done:** `control` (fallback) + `button` + `flatButton` `ControlStyle`
    slots, each with `background.color`/`background.border.width`/
    `background.border.color`/`text.color` + `hovered`/`pressed` state
    variants, translating `Theme.qml`'s `paletteFor(view)` math onto
    `root.palette.<role>` bindings (see resolved-risk section above).
    `border.width`/`.color` live under `background.border.*`, **not** a
    top-level `border` property on `ControlStyle` — got this wrong on the
    first pass (`Cannot assign to non-existent property "border"`,
    caught by the Phase 1 headless verification below), fixed to
    `background.border.width`/`background.border.color`. Grouped
    properties chain through as many levels as needed
    (`hovered.background.border.color` works fine) — no need for
    explicit `ControlStateStyle{}`/`DelegateStyle{}` object literals,
    just drill through the dot path.
  - **Deferred to Phase 2** (kept scope narrow so Phase 1's headless
    verification isolated the palette-binding risk as the only new
    variable): the other ~28 `AbstractStylableControls` slots: per the
    colorSet grep done during Phase 0 planning, Ayame's old
    window/view/header/tooltip split is *already* nearly 1:1 with
    per-control-type slots (view -> `control`/`abstractButton`/most
    controls, window -> `applicationWindow`/`pane`/`page`, header ->
    `tabBar`/`tabButton`/`toolBar`/`toolSeparator`) — should be mostly
    copy-paste of the `control` block above per group, once a widget
    needs a slot more specific than the `control` fallback it's already
    inheriting today. Also deferred: `Units.qml`'s
    `gridUnit`/`cornerRadius`(+presets)/`iconSizes`/animation
    durations(+presets)/`animationsEnabled` onto
    `padding`/`spacing`/`background.radius`/`StyleAnimation` (Button.qml
    still reads these from the old `Units.qml` singleton, only
    background/text colors + border width moved, matching Phase 1's
    original stated scope); giving `AyameStyle` its own
    `Ayame.BorderWidthSettings`/etc. instances instead of reading
    `LegacyStyleKit.Units.borderWidth`; and `CustomControl { controlType: N }`
    slots for Origami's widgets (companion task file's Phase 3, blocked on
    this file's Phase 0 landing — it now has).
  - **Open question for Phase 2:** Qt.labs.StyleKit's
    `AbstractStylableControls` has no dedicated slot for tooltips (no
    `tooltip`/`toolTip` property, and `ToolTip` isn't in
    `StyleReader.ControlType` either, per this Qt version's
    `plugins.qmltypes`) — Ayame's `ToolTip.qml` may need to stay on the
    `control` fallback style, or this needs re-investigation against a
    newer Qt.labs.StyleKit revision.
- [x] **Phase 1 — Pilot: `crates/qml6/qml/widgets/Button.qml`.** Converted
      to `import Qt.labs.StyleKit` + `StyleReader` for background/text
      colors and border width, keeping its existing `HighlightRing`/
      `IconLabel`/`Rectangle` structure. Highlight ring color originally
      stayed on a `legacyColors` property reading the old
      `Theme.paletteFor(Theme.view).highlightColor` — removed during the
      Phase 2 buttons batch once it turned out `highlightColor`/
      `highlightedTextColor` are plain, unblended `palette.highlight`/
      `palette.highlightedText` passthroughs in the old `Theme.qml` (see
      Phase 2 buttons entry below); now reads `control.palette.highlight`
      directly, no legacy `StyleKit.Theme` dependency left in this file at
      all (`StyleKit.Units` is still imported/used for icon sizes, radius,
      spacing, animation duration — out of scope, see Phase 0's deferred
      list).
      `ApplicationWindow.qml` now attaches
      `LabsStyleKit.StyleKit.style: Ayame.AyameStyle {}` (aliased import,
      `import Qt.labs.StyleKit as LabsStyleKit` — needed because this
      file already does `import StyleKit 1.0 as StyleKit` for the *old*
      crate, and Qt's own exported attached type is itself named
      `StyleKit`, which would otherwise collide with that alias) so every
      `StyleReader` in the tree resolves against one `Style` instance via
      Qt.labs.StyleKit's normal attached-property lookup — confirmed this
      is how `StyleReader` finds its style (it has no `style` property of
      its own).
      No build.rs wrinkles beyond needing `crates/qml6/qml/style/AyameStyle.qml`
      **`git add`ed** before either `nix develop`'s `cargo check` or
      `nix build` can see it — this flake's source filtering only
      includes git-tracked files, so any new file added mid-task needs
      `git add` (not commit) before Nix-driven verification will pick it
      up. Hit this once this session, worth remembering for Phase 2's
      new files too.
      Verified (2026-08-17): `cargo check -p ayame` clean; `nix build
      .#ayame` clean; headless runtime check
      (`QT_QPA_PLATFORM=offscreen cargo run -p ayame-settings`, errors via
      `journalctl --user --since <ts> -o cat`) loaded successfully and
      reached the Qt event loop with zero QML warnings beyond
      pre-existing, unrelated `cxxqt_object.cxxqt.h` moc warnings (present
      before this migration too). One real bug caught and fixed by this
      step: see the `background.border.*` note in Phase 0 above.
- [ ] **Phase 2 — Roll out to the rest of Ayame's ~57 widget files**
      (`crates/qml6/qml/widgets/**`, `crates/qml6/qml/impl/**`) using the
      same recipe validated in Phase 1. Mostly mechanical, but per-file
      judgment calls keep coming up (see buttons batch below) — no longer
      expect zero-thought copy-paste for every remaining file, budget for
      it. Per-category checklist (mirrors the 5 subtask groupings used
      this session):
  - [x] **buttons/** (`AbstractButton`, `DelayButton`, `RadioButton`,
        `RoundButton`, `TabButton`, `ToolButton` — `Button`/`FlatButton`
        already done in Phase 1). Verified 2026-08-17: `cargo check -p
        ayame` clean; headless run with a temporary off-screen
        `QQC2.AbstractButton`/`RadioButton`/`DelayButton`/`RoundButton`/
        `TabButton` row added to `ayame-settings/qml/main.qml` (reverted
        after, `git status` confirms clean — ayame-settings' real UI only
        exercises `ToolButton` on its own, so the others needed this to
        actually be instantiated and runtime-checked at all) — zero QML
        warnings beyond the pre-existing unrelated ones.
        **Reusable findings from this batch, apply to the rest of Phase 2:**
    - `highlightColor`/`highlightedTextColor` were plain
      `palette.highlight`/`palette.highlightedText` passthroughs in the
      old `Theme.qml` (no blending) — don't port these into `AyameStyle`
      at all, just read `control.palette.highlight`/`.highlightedText`
      directly in the widget file. Drops the old `StyleKit.Theme` import
      entirely wherever it was only used for this (widgets may still keep
      `StyleKit.Units` for spacing/radius/icon sizes/durations, per Phase
      0's deferred scope).
    - `hoverColor`/`pressedColor` (the `palette.highlight`-blended tints)
      are the *same* across every old colorSet, unlike
      background/text/border — one shared `_hoverColor`/`_pressedColor`
      pair on `AyameStyle`, not duplicated per colorSet.
    - Controls with no dedicated `StyleReader.ControlType`/
      `AbstractStylableControls` slot (`DelayButton`, `RoundButton`) use
      `StyleReader.AbstractButton`/`abstractButton` — matches T.DelayButton/
      T.RoundButton's own QQC2 base-type inheritance from T.AbstractButton.
    - Combined-state visuals (e.g. RadioButton's checked-border-wins-
      over-hover, ToolButton's pressed-text-color swap) turned into a
      `checked.background.border.color`/`pressed.text.color`-style
      override in `AyameStyle` + feeding the matching boolean into
      `StyleReader`, then just reading the one resolved flat value in the
      widget — no manual ternary needed in the widget file itself.
      *Not independently verified* that `StyleReader`'s internal state
      precedence exactly matches each old ternary's precedence (e.g.
      pressed-beats-hovered) — plausible/consistent with normal QQC2
      convention and loads without error, but visual confirmation is
      still out of scope for self-verification (see Verification section
      below) — flag for the user to eyeball once more categories land.
    - "Ghost" controls (`ToolButton`, `TabButton`): transparent
      `background.color` at rest, tinted on hover/press, no border --
      distinct `AyameStyle` slot shape from solid buttons, not just a
      colorSet swap.
    - Passthrough-only delegates with no rendering of their own
      (`AbstractButton.qml`, and `Control.qml` in controls/ next) still
      got a `colors` object rebuilt off `StyleReader` for API parity with
      before, even though nothing in-tree currently reads it — speculative
      external-consumer surface (`Ayame` is an exported/linkable QML
      module), kept rather than deleted since nothing confirmed it's
      truly dead.
  - [x] **controls/** (`CheckBox`, `ComboBox`, `Control`, `Dial`, `Label`,
        `PageIndicator`, `ProgressBar`, `RangeSlider`, `Slider`, `SpinBox`,
        `Switch`, `Tumbler`, `BusyIndicator`). `AyameStyle.qml` gained three
        new slots: `checkBox`, `comboBox` (with a `focused` border override,
        since it has no HighlightRing unlike Button/SpinBox), `switchControl`
        — all three needed a `checked`-state override Qt.labs.StyleKit's
        `control` fallback doesn't have, same shape as buttons batch's
        `radioButton` slot. Everything else in this category has no
        dedicated `AbstractStylableControls` slot at all (`Dial`,
        `PageIndicator`, `RangeSlider`, `Tumbler`, `BusyIndicator`, and
        `Control.qml` itself) and just falls back to `control` via
        `StyleReader.Control` — no new AyameStyle slots needed for those.
        **New findings from this batch:**
    - `RangeSlider`'s two handles (and `Slider`'s single handle) need their
      *own* `StyleReader` bound to that handle's own `hovered`/`pressed`
      (`control.first.hovered`/`control.second.hovered`, or plain
      `control.hovered`/`.pressed` for Slider) separate from a second,
      rest-only `StyleReader` for the non-interactive track — one
      `StyleReader` can only resolve one state combination at a time, so a
      widget with multiple independently-stateful visual parts needs one
      `StyleReader` per part. `SpinBox`'s up/down indicator buttons are the
      same shape, but reuse `StyleReader.ToolButton` directly (see below)
      instead of adding their own state-only slot.
    - Slider/RangeSlider's handle *fill* opacity problem (see Phase 1's
      already-resolved-for-buttons note) recurs here in a new shape: old
      code kept the handle fill flat (background color, no hover tint) and
      only forced opaque `highlightColor` on press. Reproducing that exact
      no-hover-reaction-on-fill behavior isn't expressible through a single
      `StyleReader` bound with `hovered` fed in (hover would tint the fill
      too) — accepted as a minor, deliberate behavior drift (fill now also
      gets a subtle hover tint) rather than adding more machinery; pressed
      still forces opaque `palette.highlight` directly, same as before.
      Flag for the user to eyeball alongside the other unverified
      combined-state visuals.
    - `SpinBox`'s up/down indicator buttons are ghost-styled (transparent
      at rest, tinted hover/press, no border) — textually identical to
      `ToolButton`'s look. Rather than inventing a SpinBox-indicator-shaped
      AyameStyle slot, they just use `StyleReader { controlType:
      LabsStyleKit.StyleReader.ToolButton }` directly, reusing the
      `toolButton` slot cross-control-type. `StyleReader.controlType` is
      just a lookup key into `AyameStyle`'s slots, nothing ties it to the
      control it's textually embedded in.
    - `PageIndicator`'s `subColor` (confirmed, per the pre-existing note):
      genuinely no Qt.labs.StyleKit equivalent, kept as a local
      `Qt.rgba(control.palette.text..., 0.3)` blend on the widget itself,
      same formula the old `Theme.paletteFor()` used.
    - `Label.qml`'s semantic colors (`positive`/`negative`/`neutral`) are
      similarly inexpressible in ControlStyle (no semantic-color concept at
      all) — kept as fixed hex constants directly in `Label.qml`, same
      values `StyleKit.Theme` used to hardcode.
    - Two bugs found by this batch's headless verification, neither caused
      by this migration — both widgets had simply never been instantiated
      in any headless run before (not part of `ayame-settings`' real UI,
      and not covered by the buttons batch's temporary verification row
      either):
      - `Dial.qml`: `ShapePath { strokeWidth: parent.ringThickness }` —
        `ShapePath` isn't a `QQuickItem`, so `parent` inside it means the
        `Shape` it's declared in, not that `Shape`'s own visual parent
        (where `ringThickness` actually lives) — `parent` resolves fine at
        the `Shape`-level property bindings (`_radius`, etc.) right above
        it, just not inside `ShapePath`. Fixed by giving the background
        `Item` an explicit `id: backgroundItem` and referencing that
        directly instead of `parent` inside both `ShapePath` blocks that
        needed it. Pre-existing, unrelated to StyleKit.
      - `PageIndicator.qml`: instantiating it (`count: 3`, headless) prints
        three `QQmlContext: Cannot set property on internal context.`
        warnings, one per delegate — traced to the `Repeater { model:
        control.count; delegate: control.delegate }` + delegate's `required
        property int index` combination (isolated by bisecting the
        temporary verification row: reproduces with `PageIndicator` alone,
        regardless of what the delegate's `color:` expression is). This is
        Qt's own documented idiom (this file's existing comment already
        says so: "Same Row+Repeater-over-count idiom as
        QtQuick.Controls.Basic's own PageIndicator.qml") — deviating from
        it to silence a benign engine warning felt like the wrong tradeoff,
        so left as-is. Doesn't affect rendering (each dot still gets the
        correct index/color) — flagged here rather than fixed.
        Pre-existing, unrelated to StyleKit.
        Verified 2026-08-17: `cargo check -p ayame` clean; headless run
        with a temporary `QQC2.Control`/`Dial`/`PageIndicator`/
        `ProgressBar`/`RangeSlider`/`Slider`/`Switch`/`Tumbler`/
        `BusyIndicator` row added to `ayame-settings/qml/main.qml`
        (`ayame-settings`' real UI already exercises `Label`/`CheckBox`/
        `ComboBox`/`SpinBox` on its own, confirmed clean before adding the
        temporary row too; reverted after, `git status` confirms clean) —
        zero QML warnings beyond the pre-existing moc warnings and the two
        pre-existing bugs above (one fixed, one flagged-not-fixed).
        `nix build .#ayame` also clean.
  - [x] **containers/** (`Container`, `Frame`, `GroupBox`, `Page`, `Pane`,
        `SplitView`, `StackView`, `SwipeView`, `TabBar`, `ToolBar`).
        `ScrollView` deliberately **not** converted here — it's pure
        pass-through (`colorSet` handed straight to its two
        `Ayame.ScrollBar` children, no rendering of its own), tightly
        coupled to `widgets/scroll/ScrollBar.qml`, which is next batch's
        job (`inputs/menus/popups/scroll/impl`) — converting one side
        without the other would leave `ScrollBar.qml` broken. Left as the
        one remaining `StyleKit.Theme` reference in this directory,
        on purpose.
        Unlike buttons/controls (all `view` colorSet), this category mixes
        `view` (`Container`/`Frame`/`GroupBox`/`SplitView`), `window`
        (`Page`/`Pane`/`StackView`/`SwipeView`), and `header`
        (`TabBar`/`ToolBar`) — `AyameStyle.qml` gained `_windowBackground`/
        `_windowText`/`_windowBorder`/`_windowHoverBorder` (mirroring the
        existing `_view*`/`_header*` triplets) plus four new slots:
        `page`, `pane` (both just `background.color`, matching what those
        two files actually read before), `tabBar` (ditto), `toolBar`
        (adds a border). `Container`/`Frame`/`GroupBox`/`SplitView` needed
        no new slots — despite having dedicated `AbstractStylableControls`
        entries (`frame`, `groupBox`), their old look was identical to
        `control`'s own view-colorSet default, so they just cascade.
        `StackView`/`SwipeView` have no dedicated slot either and fall
        back to `control` (view, not their old `window`) — harmless in
        practice since both files' `colors` property has never actually
        been read anywhere (no background `Rectangle` in either), same
        passthrough-only situation as `AbstractButton.qml`/`Control.qml`.
        **Three pre-existing bugs found by this batch's headless
        verification** (same pattern as Phase 2's `controls/` batch:
        none of these files had ever actually been instantiated before,
        since `ayame-settings`' real UI only exercises `Page`) — all
        fixed alongside the color-source migration since verification
        caught them directly in the files being touched:
    - `SplitView.qml`: bare `SplitHandle.pressed`/`.hovered` is an
      unresolved identifier — confirmed against Qt's own Basic-style
      `SplitView.qml`, which spells it `T.SplitHandle` (it's a
      `QtQuick.Templates` attached type, and this file only imports
      Templates as `T`, no bare `QtQuick.Controls`). Fixed to
      `T.SplitHandle.pressed`/`.hovered`.
    - `StackView.qml`: `contentWidth`/`contentHeight` don't exist on
      `T.StackView` — unlike every other file in this directory,
      `QQuickStackView`'s prototype is `QQuickControl` directly, not
      `QQuickContainer` (confirmed via `QtQuick.Templates`'
      `plugins.qmltypes`: `Pane`/`Frame`/`GroupBox`/`Page`/`ToolBar` are
      all `QQuickPane`, which independently redeclares
      `contentWidth`/`contentHeight` itself, so those five were fine
      as-is). Fixed to `implicitContentWidth`/`implicitContentHeight`,
      `Control`'s own equivalent.
        Verified 2026-08-17: `cargo check -p ayame` clean; headless run
        with a temporary `QQC2.Container`/`Frame`/`GroupBox`/`Pane`/
        `SplitView`/`StackView`/`SwipeView`/`TabBar`/`ToolBar` row added to
        `ayame-settings/qml/main.qml` (real UI only exercises `Page` on
        its own; reverted after, `git status` confirms clean) — zero QML
        warnings beyond the pre-existing moc warnings, after fixing the
        three bugs above. `nix build .#ayame` also clean.
  - [x] **delegates/** (`CheckDelegate`, `ItemDelegate`, `RadioDelegate`,
        `SwipeDelegate`, `SwitchDelegate`) — all five used the identical
        old `view`-colorSet "ghost" background (`pressed ? pressedColor :
        (hovered ? hoverColor : "transparent")`), textually the same shape
        as `toolButton`. `AyameStyle.qml` gained one new slot,
        `itemDelegate` (that ghost background + a `highlighted.text.color`
        override, since `ItemDelegate`/`SwipeDelegate` swap text color
        when `highlighted` rather than on hover/press) — the semantically
        correct `AbstractStylableControls` entry for this shape, used by
        all five widgets even though only `ItemDelegate`/`SwipeDelegate`
        actually needed just that (no indicator of their own).
        `CheckDelegate`/`RadioDelegate`/`SwitchDelegate` layer a *second*
        `StyleReader` on top for their indicator, reusing
        `checkBox`/`radioButton`/`switchControl` respectively (the same
        slots `widgets/controls/CheckBox.qml`/`buttons/RadioButton.qml`/
        `controls/Switch.qml` already read) — same "reuse an existing slot
        across control types" trick as `SpinBox.qml`'s up/down indicators
        reusing `toolButton` in the controls/ batch. Minor, accepted
        precision loss: reusing those three slots means CheckDelegate's/
        RadioDelegate's/SwitchDelegate's indicators now also react to
        hover on their border (their old code never varied indicator
        border by hover, only by checked) — same class of deliberate
        drift as prior batches' combined-state approximations, flagged
        rather than engineered around.
        Verified 2026-08-17: `cargo check -p ayame` clean; headless run
        with a temporary `QQC2.CheckDelegate`/`ItemDelegate`/
        `RadioDelegate`/`SwipeDelegate`/`SwitchDelegate` row added to
        `ayame-settings/qml/main.qml` (none of the five are exercised by
        the real UI directly; reverted after, `git status` confirms
        clean) — zero QML warnings beyond the pre-existing moc warnings.
        `nix build .#ayame` also clean. (A `No StyleKit style has been
        set!` warning was reported mid-session but traced to `origami`,
        not this file's own widgets or this headless run's own log —
        unrelated to this batch, left for whenever Origami's own Phase 3
        migration starts.)
  - [x] **inputs/menus/popups/scroll/impl** (`TextArea`, `TextField`,
        `Action`, `ActionGroup`, `Menu`, `MenuItem`, `MenuSeparator`,
        `Dialog`, `DialogButtonBox`, `Drawer`, `Popup`, `ToolTip`,
        `ScrollBar`, `ScrollIndicator`, `ToolSeparator`,
        `impl/HighlightRing.qml`, `impl/TrackBar.qml`) — the last Phase 2
        batch. `Action.qml`/`ActionGroup.qml`/`impl/HighlightRing.qml`/
        `impl/TrackBar.qml` needed **no changes at all**: the first two
        never read any color, and the impl pair only ever took colors as
        plain caller-supplied parameters (`ringColor`/`trackColor`/
        `trackBorderColor`) — never touched `StyleKit.Theme` themselves,
        only their *callers* did, and those callers were already migrated
        in earlier batches.
        **`ToolTip`'s Phase 0 open question is now resolved: still no
        `AbstractStylableControls` slot for it** (confirmed against this
        Qt version's `StyleReader.ControlType` enum one more time) --
        same for `Menu`/`MenuItem`/`MenuSeparator`/`Dialog`/
        `DialogButtonBox`/`Drawer`/`StackView`/`SwipeView`/`SplitView`
        from earlier batches. This turned out to be a *common* situation,
        not a `ToolTip`-specific gap, and the migration now has an
        established two-tier response to it:
    - If the old colorSet was `view` and the widget has no dedicated
      slot, it silently falls back to `control` with **zero code
      changes needed** (e.g. `Dialog.qml`, `Popup.qml`, `DialogButtonBox.qml`)
      -- `control` already *is* the view look.
    - If the old colorSet was something else (`window`/`header`/the
      one-off `tooltip`), the color math is computed **locally on the
      widget itself**, reading straight off `control.palette.*` --
      same pattern PageIndicator's `subColor`/Label's semantic colors
      established in the controls/ batch. New instances this batch:
      `Menu.qml`/`MenuItem.qml` (header), `ToolTip.qml` (a new,
      one-off `palette.light`/`.windowText` pair -- confirmed no other
      colorSet in the old `Theme.qml` used this combination).
      `Drawer.qml` (window) instead **reuses** `containers/Pane.qml`'s
      `pane` slot rather than going local, since `pane`'s look (window
      colorSet, background-only) already matched what Drawer needed --
      `pane` gained a `background.border.*` override in `AyameStyle.qml`
      for this reuse (`Pane.qml` itself never read it, so silently
      unused there). `MenuSeparator.qml` similarly reuses
      `scroll/ToolSeparator.qml`'s own new `toolSeparator` slot (a
      real `AbstractStylableControls` entry, unlike Menu's family) --
      the old `subColor` and `borderColor` were always the *same*
      formula in `Theme.qml` for every colorSet, so `toolSeparator`'s
      one property doubles as both.
    - `containers/ScrollView.qml`, deferred from the containers/ batch
      specifically to land alongside `scroll/ScrollBar.qml`: now
      converted together. `ScrollBar.qml` dropped its `colorSet`
      property entirely (reads `control.palette`/local blend directly,
      no dedicated slot needed -- old look matched `control`'s), so
      `ScrollView.qml`'s `Ayame.ScrollBar { colorSet: control.colorSet }`
      forwarding became dead and was deleted along with `ScrollView.qml`'s
      own now-unused `colorSet` property and `StyleKit` import.
        Verified 2026-08-17: `cargo check -p ayame` clean; headless run
        with a temporary `QQC2.TextArea`/`ScrollIndicator`/
        `ToolSeparator`/`ScrollView`/`Menu`+`MenuItem`+`MenuSeparator`/
        `Dialog`/`DialogButtonBox`/`Drawer`/`Popup`/`ToolTip` block added
        to `ayame-settings/qml/main.qml` (`visible: true` on every
        Popup-family one, since none of these are exercised by the real
        UI except `TextField`; reverted after, `git status` confirms
        clean) — zero QML warnings beyond the pre-existing moc warnings.
        `nix build .#ayame` also clean.
        **Phase 2 is now fully complete** (buttons/controls/containers/
        delegates/inputs-menus-popups-scroll-impl, all five batches
        landed and verified).
- [ ] **Phase 4 — Retire `crates/stylekit`.** Status as of Phase 2
      completing (2026-08-17): `grep -rlE "StyleKit\.Theme\b"` across
      `ayame` now returns **nothing** (`ApplicationWindow.qml` is the one
      remaining real reference, `window.colors.backgroundColor` for the
      app chrome itself -- not covered by any Phase 2 batch, needs its
      own small pass before Theme.qml can actually be deleted).
  - [x] **`ApplicationWindow.qml`'s small pass (2026-08-18).** Confirmed
        via qmltypes (`plugins.qmltypes` for both `Qt.labs.StyleKit` and
        `QtQuick.Templates`) that `applicationWindow` is a real
        `AbstractStylableControls` slot / `StyleReader.ControlType` value,
        and `T.ApplicationWindow` (unlike a bare `Window`) does expose a
        `palette` property to bind a `StyleReader` against -- no workaround
        needed, same recipe as `page`/`pane`. `AyameStyle.qml` gained an
        `applicationWindow: ControlStyle { background.color:
        root._windowBackground }` slot (reusing the existing `_windowBackground`
        from the containers/ batch, no new palette math). `ApplicationWindow.qml`
        itself: dropped `colorSet`/`colors` properties and the legacy
        `import StyleKit 1.0 as StyleKit` entirely (confirmed via grep
        nothing outside this file ever read `window.colors`/`.colorSet`),
        added a `LabsStyleKit.StyleReader { controlType:
        LabsStyleKit.StyleReader.ApplicationWindow; palette: window.palette }`,
        `color: styleReader.background.color`. `grep -rnE "StyleKit\.Theme"`
        across the tree now only matches comments (4 files, all prose
        referencing the old singleton by name, no live code) -- the real
        migration is done.
        Verified 2026-08-18: `cargo check -p ayame` clean; `cargo build -p
        ayame-settings` clean; headless run (`QT_QPA_PLATFORM=offscreen
        timeout 8 cargo run -p ayame-settings`, confirmed actually reached
        `Running` via stdout, errors checked via `journalctl --user --since
        <ts> -o cat`) showed zero QML warnings beyond the pre-existing,
        unrelated moc/`_FORTIFY_SOURCE` noise. `git status` shows only the
        two intended files changed.
      `grep -rlE "StyleKit\.Units\b"` still returns ~35 files -- **decision
      revised 2026-08-18, confirmed with the user: `crates/stylekit` is not
      being deleted.** `Units.qml` is a general app-wide design-token +
      live-settings-mutation singleton (`gridUnit`/`smallSpacing`/
      `largeSpacing`/`iconSizes`/`collapsedDrawerSize`/`groupContentMargin`,
      plus `setUiScale()`/`setCornerRadiusOption()`/`setAnimationSpeedOption()`/
      `setAnimationsEnabled()`/`persist()`/`cancel()`/`resetToDefaults()`/
      `default*()` called directly by `ayame-settings`' Appearance page) --
      most of it has no equivalent in `Qt.labs.StyleKit`'s read-only
      `Style`/`ControlStyle` model and stays in `Units.qml` permanently.
  - [x] **`cornerRadius` migrated (2026-08-18, ex-Units-follow-up-task,
        file deleted after completion).** Investigated every `Units.qml`
        member against actual widget-file usage: `cornerRadius` (23 uses)
        is the only one shaped like `borderWidth` (single global value ->
        `ControlStyle.background.radius`, confirmed real property via
        `plugins.qmltypes`) -- migrated. `gridUnit`/`smallSpacing`/
        `largeSpacing`/`iconSizes.*` (124 uses) drive arbitrary item
        geometry across both QQC2 widgets and plain layout code, not
        "control style" data -- no `ControlStyle` equivalent exists, left
        alone permanently. `shortDuration`/`veryLongDuration`/
        `animationsEnabled` (18 uses): investigated `Qt.labs.StyleKit`'s
        `StyleAnimation` type directly (`StyleAnimation.qml`) -- it's a
        `ParallelAnimation`-based `Behavior` component with one shared
        `duration`/`easing`, not readable duration constants; adopting it
        would mean giving up Ayame's short/long/veryLong tiering for no
        gain -- left alone permanently.
        `AyameStyle.qml` gained `readonly property real _cornerRadius:
        LegacyStyleKit.Units.cornerRadius` (same deliberate-passthrough
        pattern as `borderWidth`) plus `background.radius: root._cornerRadius`
        on the 8 slots any in-scope site resolves through (`control`,
        `button`, `flatButton`, `abstractButton`, `checkBox`, `comboBox`,
        `itemDelegate`, `toolButton`). 21 of 23 `Units.cornerRadius` read
        sites (17 widget files) already had a `StyleReader` wired to that
        exact background `Rectangle` for color/border -- swapped to
        `styleReader.background.radius` (or `indicatorStyleReader`/
        `upStyleReader`/`downStyleReader` where applicable). 2 sites left
        as direct `StyleKit.Units.cornerRadius` reads, matching this
        migration's established "don't add a `StyleReader` to a file that
        never needed one for colors either" precedent:
        `impl/HighlightRing.qml` (reusable leaf, no per-caller StyleReader
        ever) and `widgets/menus/MenuItem.qml` (no StyleReader at all,
        unlike sibling `Menu.qml` which already had one for border-width
        and picked up radius too).
        Verified 2026-08-18: `cargo check -p ayame -p ayame-settings`
        clean; headless run with a temporary verification block in
        `ayame-settings/qml/main.qml` covering every touched widget the
        real UI doesn't already exercise (`DelayButton`/`Tumbler`/
        `DialogButtonBox`/`CheckDelegate`/`ItemDelegate`/`Frame`/
        `GroupBox`/`TextArea`/`Dialog`/`Popup`/`ToolTip`/`Menu`+`MenuItem`,
        `visible: true` on the Popup-family ones) showed zero QML warnings
        beyond the pre-existing moc/`_FORTIFY_SOURCE` noise; block reverted
        after, `git status` confirms `main.qml` clean.
      Full deletion of `crates/stylekit` remains off the table for the
      reasons above (`Units.qml`'s generic-sizing + live-settings-mutation
      role has no replacement), independent of `origami-frameworks`' own
      Phase 3 (its task file, cross-referenced at the top of this one),
      which also remains unstarted.
- [ ] Delete this file once done and confirmed working.
