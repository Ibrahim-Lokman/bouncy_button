# bouncy_button 2.1 to-do list

2.1 is a minor release, so nothing here may change how existing apps look or behave. Anything that would is listed under [Later, in 3.0](#later-in-30).

## From Apple's button guidelines

Source: [Apple Human Interface Guidelines, Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons), last updated December 16, 2025.

- [x] **Destructive style**
  - **Why:** Apple uses red for buttons that can destroy data. Today users must set `backgroundColor` by hand.
  - **What:** a destructive option that works with every fill, using the theme's error colors: filled on `error`, tonal on `errorContainer`, and outlined or ghost with `error` text.
  - **Done when:** text meets 4.5:1 contrast for every fill in light and dark themes, and the gallery shows it.

- [x] **Loading with a label**
  - **Why:** Apple shows the spinner next to the label, which can change while loading, such as "Checkout" becoming "Checking out…". Today the default replaces the label with a spinner.
  - **What:** an option on `BouncyButtonFeedback`, such as `loadingText`, that shows the spinner beside a label. The current spinner-only default stays.
  - **Decided:** the button keeps its size, and longer text is cut off with an ellipsis, so the layout never jumps.
  - **Done when:** tests cover the width behavior and what screen readers announce.

- [x] **Tooltip**
  - **Why:** macOS shows a short tooltip when hovering over a button, and icon-only buttons need one most. Material's `IconButton` has a `tooltip` setting.
  - **What:** a `tooltip` on `BouncyButton` that also names icon-only buttons for screen readers, without reading the name twice.
  - **Note:** `Tooltip` is a Material widget, and `BouncyPressable` must stay free of Material, so it needs a different approach or should go without.

- [x] **Minimum tap target, opt-in**
  - **Why:** Apple asks for a hit region of at least 44×44 pt. A button set smaller than that today also gets a smaller tap area. Material pads small buttons up to 48.
  - **What:** an opt-in setting that enlarges the tap area to 48 without changing how the button looks.
  - **Note:** Flutter can only accept taps inside a widget's layout bounds, so the padding adds layout space. That's why this is opt-in now and could become the default in 3.0.

- [x] **Guidance on choosing styles**
  - **Why:** Apple says to "use style — not size — to visually distinguish the preferred choice". `BouncyButton.secondary` and `.tertiary` currently differ from primary only by size.
  - **What:** a README section on choosing a fill, such as filled for the main action, tonal for secondary, outlined or ghost for the rest, and destructive. Point to it from the doc comments of `.secondary` and `.tertiary`.

- [x] **Example app: fewer prominent buttons**
  - **Why:** Apple advises one or two prominent buttons per view. After a successful checkout, the example shows three solid buttons: Apply, Pay, and Start a new order.
  - **What:** make Apply tonal and Start a new order outlined, so Pay is the only solid button.

## Still open from 2.0

- [ ] **Check on real devices:** springs, haptics, sounds, glass, and a screen reader (TalkBack and VoiceOver) haven't been checked on real hardware or by a person.
- [x] **Rename generic public names:** `HapticFeedbackType` and `GradientExtension` could clash with other packages. Add prefixed names and deprecate the old ones, which keeps 2.1 non-breaking.
- [x] **Continuous integration:** run analysis and tests on every push, on Flutter 3.27 and the latest stable release. Added in `.github/workflows/ci.yml`; it runs for the first time once pushed.
- [ ] **Golden tests:** add screenshot tests for each fill and state, so visual bugs like the 2.0 ghost and glass depth layer are caught automatically.
- [x] **GitHub description:** the repository's description still uses the 1.x wording. Match it to the pub.dev description.

## New features

### From tap_debouncer

Source: tap_debouncer 2.2.0, last released May 2023, about 17,000 downloads a month. That's around six times more than any loading-button package. Analysis on 2026-11-02 covered its source, its issue history, and 13 competing packages.

- [x] **Cooldown**
  - **Why:** tap_debouncer's `cooldown` ignores presses for a while after an action finishes. bouncy_button's plain `onPressed` has no protection at all, so a quick double tap on `() => Navigator.push(...)` opens the page twice.
  - **What:** a `cooldown` duration on `BouncyButton` and `BouncyPressable`, for both `onPressed` and `onPressedAsync`.
  - **Avoid their bugs:**
    - Cool down after errors too. tap_debouncer skips it, despite its README.
    - Run the timing on an animation, not a timer, so tests can use `pumpAndSettle`.
    - Offer "only once" as an explicit option, not a huge duration. tap_debouncer's `kNeverCooldown` probably overflows on web.

- [x] **Async protection for any button**
  - **Why:** tap_debouncer's main draw is that it wraps the buttons people already use. bouncy_button only protects its own button.
  - **What:** a builder widget, for example `BouncyAsyncBuilder`, that passes the builder a guarded callback and the current status (idle, loading, success, error). It should need no Material code, so it can go in `package:bouncy_button/pressable.dart`.
  - **Avoid their bugs:**
    - Block repeat taps immediately with a flag. tap_debouncer waits for a rebuild, so two taps in the same frame can both run.
    - Don't disable the wrapped button by passing it a null callback, which drops keyboard focus.
    - Report errors instead of leaving them uncaught.

- [x] **Controller**
  - **Why:** six of the 13 rival packages have one.
  - **What:** a `BouncyButtonController` that can start the action from code, reset the button, and report its status.

- [x] **Group lock**
  - **Why:** in a login screen with "Sign in with Google" and "Sign in with Apple", only one sign-in should run at a time. Only loadable_buttons does this.
  - **What:** while one async button in a scope is loading, the others in it ignore presses. Extend `BouncyExclusiveScope`, which today only stops presses that happen at the same moment.

- [x] **Minimum loading time**
  - **Why:** a very fast request makes the spinner flash for a frame, which looks like a glitch.
  - **What:** a `BouncyButtonFeedback` option that keeps loading on screen for a minimum time.

- [x] **Migration guide from tap_debouncer**
  - **Why:** its users are looking for a maintained replacement, and its README samples no longer compile because they use `RaisedButton`.
  - **What:** a README section mapping `onTap` to `onPressedAsync`, `waitBuilder` to `loadingBuilder`, `cooldown` to `cooldown`, and wrapped buttons to the new builder widget.

Considered and left out: a timeout for stuck requests and per-tap cancellation modes. Each is offered by only one rival package.

### Your features

- [ ] _Add your 2.1 features here._

## Later, in 3.0

These change how existing apps look, so they wait for a major version:

- `BouncyButton.secondary` and `.tertiary` default to tonal and outlined fills.
- The minimum tap target becomes the default.
- Move from `package:flutter/material.dart` to `material_ui`, once Flutter announces a deprecation date.

## Release checklist

- [x] Bump `pubspec.yaml` to 2.1.0. The `CHANGELOG.md` entry still needs its date.
- [x] `flutter analyze` and `flutter test` pass, in the package and `example/`, on Flutter 3.27, current, and latest stable.
- [ ] The example app runs on a device, and each new feature has been checked by eye. Checked as rendered screenshots, not yet on a device.
- [x] `flutter pub publish --dry-run` shows 0 warnings.
- [ ] Publish, then tag `v2.1.0` and push as the `Ibrahim-Lokman` account.
