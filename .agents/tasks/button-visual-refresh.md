# Button visual refresh: color transitions + rotating gradient ring

## Goal
Make `Button.qml` more polished: smooth color transitions on hover/press/focus,
and a rotating conic-gradient "spinning light" ring around the border when
`control.highlighted` is true (the primary/default-action button state).

Confirmed with user: no size/scale animations (Ayame doesn't do those). The
rotating border idea (user's own suggestion) is the centerpiece.

## Environment findings (do not re-derive)
- Qt 6.11.1 via nix flake, `QtQuick.Shapes` module (`ConicalGradient`,
  `PathRectangle` since Qt 6.8) is available and confirmed present in
  qmltypes at `/nix/store/.../qtdeclarative-6.11.1/lib/qt-6/qml/QtQuick/Shapes/`.
- `crates/qml6/build.rs` currently links only `.qt_module("Quick")` and
  `.qt_module("QuickControls2")`. Need to add `.qt_module("QuickShapes")`
  (pkg-config name confirmed: `Qt6QuickShapes.pc` exists alongside
  `Qt6Quick.pc`/`Qt6QuickControls2.pc`).
- `T.Button` (`QQuickButton`) already has a native `highlighted` bool
  property (confirmed via Templates qmltypes) -- no need to add a custom
  property for the "active/primary" trigger state.
- `Ayame.Units` already exposes animation duration constants
  (`veryShortDuration`/`shortDuration`/`longDuration`/`veryLongDuration`)
  that collapse to `0` when the user disables animations in settings
  (`Units.animationsEnabled`) -- existing convention is to bind `Behavior`
  durations directly to these without extra `enabled:` guards, since 0
  duration already means instant/no-op. Follow this convention for the new
  color-transition Behaviors.
- No widget in the codebase currently has any real `Behavior`/animation
  block (grepped whole `crates/qml6/qml` tree) -- Button.qml will be the
  first, so this also sets the pattern other widgets can follow later.
- The continuous rotation NumberAnimation (not a Behavior) must be gated
  with `running: control.highlighted && Ayame.Units.animationsEnabled`
  (explicit, not relying on duration=0) to avoid a zero-duration busy-loop
  when animations are disabled app-wide.

## Steps
1. [x] Add `.qt_module("QuickShapes")` to `crates/qml6/build.rs`.
2. [x] Rewrite `crates/qml6/qml/widgets/Button.qml`:
   - Add `Behavior on color` / `Behavior on border.color` to the background
     Rectangle (durations from `Ayame.Units.shortDuration`).
   - Wrap background in an `Item` containing the existing background
     `Rectangle` plus a new `Shape` (`import QtQuick.Shapes`) that draws a
     ring (two `PathRectangle`s inside one `ShapePath` with
     `fillRule: ShapePath.OddEvenFill`, outer = full bounds, inner = inset
     by `Ayame.Units.borderWidth`) filled with a `ConicalGradient` whose
     `angle` is animated 0->360 in an infinite loop.
   - Ring `Shape` only visible/running when `control.highlighted` and
     `Ayame.Units.animationsEnabled`.
   - Add a subtle `Behavior on color` to the contentItem `Text` color too.
3. [~] `cargo check -p ayame` (NOT `-p qml6` -- the crate's package name is
   `ayame`) to confirm it links and compiles.
   - Confirmed baseline (unmodified repo, via `git stash`) builds clean.
   - Confirmed the `QuickShapes` `.qt_module()` addition alone panicked at
     build-script time: "Could not find a prl path for Qt module:
     QuickShapes" -- the nix devshell's `qt6-lib-with-prl` derivation
     (`nix/qt-toolchain.nix`) only synthesizes `.prl` files for
     `Qt6Qml`/`Qt6Quick`/`Qt6QuickControls2`. Fixed by adding
     `Qt6QuickShapes` to that loop.
   - That nix fix requires a fresh-evaluated devshell to take effect
     (`QMAKE` env var in the already-loaded interactive shell points at the
     old derivation output). Verified via `nix develop --command bash -c
     'cargo check -p ayame'` that the QuickShapes prl error is gone (build
     progressed past the build-script/linking stage).
   - **IMPORTANT -- do not re-run full-workspace builds or `git stash`
     right now**: discovered mid-task that another concurrent session is
     live-editing this same repo implementing a separate feature (see
     `.agents/tasks/ayamerc-config-crate.md` -- new `ayame-config` crate at
     `crates/config`, touches `crates/qml6/build.rs`,
     `crates/qml6/src/cxxqt_object.rs`, `crates/qml6/src/lib.rs`, and
     `crates/qml6/Cargo.toml`). The last `cargo check -p ayame` run failed
     with `E0433 cannot find module ayame_config` -- caught their work
     mid-edit, unrelated to this task's changes. User confirmed (via
     AskUserQuestion): wait for their work to land, re-verify the full
     build afterward instead of using worktree isolation.
   - `git stash`/`git stash pop` were used twice for testing before this
     was discovered -- both completed cleanly (no conflicts), all changes
     (mine and theirs) confirmed still present afterward. Avoid repeating
     this; it risks racing with their concurrent edits.
4. [ ] Once the other session's `ayame-config` work has landed (check
   whether `.agents/tasks/ayamerc-config-crate.md` still exists / ask the
   user), re-run `cargo check -p ayame` for a real end-to-end verification.
5. [ ] Visually verify with the `run` skill / actual app launch if
   feasible; otherwise state clearly that only compilation was verified,
   not the rendered look.
6. [ ] Delete this task file once done.

## User feedback round 2 (2026-08-15)
- "背景のアニメーションは要らない" -- removed both `Behavior on color` and
  `Behavior on border.color` from the background `Rectangle` (the fill/
  border-color hover-fade). Left the `contentItem` Text's `Behavior on
  color` alone (not mentioned, not "background").
- "ボーダーがアニメーションしていない" -- the spinning ring isn't visibly
  rotating. Not yet root-caused. Reviewed the QML logic again (Shape /
  ShapePath / ConicalGradient / PathRectangle / NumberAnimation wiring)
  and didn't find an obvious bug; Qt Quick Shapes is designed to support
  live-animated gradient properties (angle has a NOTIFY signal, ShapePath
  wires up a generic path-changed callback on gradient changes). Two
  candidate explanations, unconfirmed:
  1. A real rendering bug (Shape not repainting on `ConicalGradient.angle`
     change on this Qt/renderer combination) -- would need direct visual
     testing to confirm.
  2. The effect is just too subtle to notice: gradient stops only light up
     a ~79 degree arc (0.78-1.0 range) on what's likely a 1-2px-thick ring
     on a small button -- technically animating but hard to see.
- Attempted to visually verify myself via `nix shell nixpkgs#grim` +
  launching `ayame-settings` and screenshotting. This caused two problems:
  1. Multiple parallel `nix develop`/`nix shell` invocations caused nix
     eval-cache (SQLite) lock contention that visibly disrupted the user's
     other live terminal sessions/other projects (saw
     "direnv: error signal: killed" / "interrupted by the user" appear in
     an unrelated pane).
  2. `grim` with no args screenshots the *entire* desktop -- captured
     unrelated windows (other repos, another Claude Code session's
     conversation). Deleted that screenshot immediately; did not act on or
     reference its unrelated contents.
  User decided (AskUserQuestion): they will launch `ayame-settings`
  themselves and report back what they see, rather than me doing more
  desktop-affecting verification. **Do not launch `nix develop`/`nix
  shell`/screenshot the desktop again for this task unless the user asks.**
  The already-built binary is at `target/debug/ayame-settings`; running it
  directly (no `nix develop` wrapper) in an already-loaded shell is fine if
  ever needed again, but avoid full-desktop screenshots (crop/target the
  window only, or better: let the user look).
- Next step: wait for the user's manual observation, then root-cause
  precisely (which of the two candidate explanations above, or something
  else) before changing the ring implementation further.
