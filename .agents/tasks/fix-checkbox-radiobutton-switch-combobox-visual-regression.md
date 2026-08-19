# Fix visual regression in CheckBox/RadioButton/Switch/ComboBox

Reported by the user (2026-08-18) after the first real visual inspection of
the `Qt.labs.StyleKit` migration (`.agents/tasks/migrate-to-qt-labs-stylekit.md`)
— all prior verification in that migration was headless-only (`cargo check`
+ `QT_QPA_PLATFORM=offscreen` + journalctl, explicitly flagged multiple
times as "not a substitute for someone actually looking at it").

## Symptoms (as reported, not yet root-caused)

- **CheckBox / RadioButton / Switch**: `checked`/`hovered`/`pressed` state
  colors and/or borders look wrong.
- **ComboBox**: its dropdown popup does not open.

These are two structurally different bugs (state-color logic vs. a
popup-visibility/sizing failure), likely with different root causes —
investigate separately, don't assume one fix covers both.

## Relevant prior context (leads, not conclusions)

- `crates/qml6/qml/style/AyameStyle.qml`'s `checkBox`/`comboBox`/
  `switchControl` slots (controls/ batch) and `radioButton` slot (buttons/
  batch) each added a `checked`/`focused` state override on top of
  Qt.labs.StyleKit's own state-resolution machinery. The original task
  file flagged this explicitly as unverified:
  > Not independently verified that `StyleReader`'s internal state
  > precedence exactly matches each old ternary's precedence (e.g.
  > pressed-beats-hovered) ... flagged for the user to eyeball once more
  > categories land.
  This is the most likely first place to look for the checked/hover/
  pressed color issue.
- `ComboBox.qml`'s popup is `Ayame.Popup { ... }` (`crates/qml6/qml/widgets/
  popups/Popup.qml`), which itself falls back to the `control`
  (StyleReader) slot with no dedicated AyameStyle override. Read
  `Popup.qml` in full during triage (2026-08-18): nothing there
  obviously blocks opening (no visibility/transition override, no
  `open()`/`close()` override) — `implicitWidth`/`implicitHeight`
  resolving to 0 (making the popup technically open but invisible) is one
  plausible lead worth checking before assuming it's a genuine
  open/close-logic bug. `ComboBox.qml`'s own `popup: Ayame.Popup { y:
  control.height; width: control.width; height: Math.min(contentItem.
  implicitHeight, ...) }` is the other place to check.
- Both `CheckBox.qml` and `ComboBox.qml` (2 of the 4 affected widgets) had
  their `radius:` line changed today by
  `.agents/tasks/migrate-to-qt-labs-stylekit.md`'s cornerRadius follow-up
  (`radius: StyleKit.Units.cornerRadius` -> `radius: styleReader.
  background.radius`) — worth explicitly ruling in/out as a cause, even
  though that change only touches `background.radius` and shouldn't affect
  state-color logic or popup open/close behavior. `RadioButton.qml`/
  `Switch.qml` were **not** touched by that change (they draw no
  radius-consuming background rect), so if all four widgets turn out to
  share one root cause, it's not the cornerRadius change.

## Steps

- [ ] Reproduce visually (`cargo run -p ayame-settings` or another real
      GUI session, not headless) and get a precise description of what's
      wrong for each of CheckBox/RadioButton/Switch (which state, which
      property — background color, border color, or both; screenshot if
      possible).
- [ ] For the state-color issue: compare `AyameStyle.qml`'s `checkBox`/
      `radioButton`/`switchControl`/`comboBox` slots' `checked`/`hovered`/
      `pressed`/`focused` overrides against the old `Theme.qml`'s
      per-widget ternary logic (git history has it, or `crates/stylekit/
      qml/theme/Theme.qml` if not yet deleted) to find the actual
      precedence mismatch.
- [ ] For ComboBox's popup: add temporary debug output (or a debugger) to
      check whether the popup actually opens (visible: true, non-zero
      size) but renders wrong, vs. never opening at all (T.ComboBox's
      `popup.open()` never firing). Narrow down whether the cause is in
      `ComboBox.qml` itself or in `Popup.qml`.
- [ ] Fix root cause(s) found above.
- [ ] Verify: `cargo check -p ayame` clean, headless run clean (existing
      technique), **and** real visual/interactive confirmation this time
      (not headless-only) — click through checked/hover/pressed states on
      all three, and actually open the ComboBox dropdown.
- [ ] Delete this file once done and confirmed working.
