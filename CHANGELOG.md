## [2.2.0] - 2026-11-03

This release goes through a checklist of common button mistakes, and makes each one either impossible or easy to spot.

### Added

- `timeout` on `BouncyButton` and `BouncyAsyncBuilder`. An action that runs too long shows an error, passes a `TimeoutException` to `onError`, and frees the button and any group lock. Its late result is ignored, but a late error is still reported. Off by default.
- `confirm` on `BouncyButton` and `BouncyAsyncBuilder`, asked before the action runs, such as to show a dialog. The action runs only on `true`. While it waits, presses are ignored and no spinner shows.
- `BouncyButton.icon`, which requires a `tooltip`, so an icon-only button always has a name. It uses the new `BouncyButtonStyle.icon` preset, which is round with a 48 by 48 tap area, or `BouncyButtonTheme.iconStyle`.
- `isSelected` on `BouncyButton` and `BouncyPressable`, for toggles. Screen readers announce them as checked or not checked.
- `expanded` on `BouncyButton` and `BouncyPressable`, for buttons that open a menu or section.
- `BouncyButton.disabledReason`, shown as a tooltip and read by screen readers while the button is disabled.
- `statesController` on `BouncyButton` and `BouncyPressable`, which follows pressed, hovered, focused, disabled, and selected.
- `BouncyButtonStyle.minWidth`, a minimum width that still lets longer labels fit.
- `BouncyButtonGroup.showSelectedIcon` and `selectedIcon`, which mark selected segments with a check, so the selection doesn't rely on color alone.
- Tooltips now also show while a button has keyboard focus.
- Debug-only warnings, printed once each, for an icon-only button with no label, a `semanticLabel` that leaves out the visible text, a tappable widget inside a button, a toggle whose text changes with its state, text below WCAG contrast, a tap area smaller than 48 by 48 (44 by 44 on Apple platforms), and English screen reader labels in an app using another language. Turn them off with `debugBouncyChecksEnabled = false`.
- `package:bouncy_button/testing.dart` with `expectAccessibleButton`, which checks a button with Flutter's accessibility guidelines and makes sure a double tap and a held Enter key each run it once. `flutter_test` is now a dependency for it. Release builds don't include it.

### Fixed

- Holding Enter, Space, or another activation key pressed a button over and over, because the app's shortcuts turned each key repeat into another press. It now presses once.
- A button with a controller could report "can only be attached to one widget at a time" when a list moved it to another position.
- When the system asks apps to turn animations off, such as Remove animations on Android, Flutter shortened `cooldown`, `minLoadingDuration`, and `resultDuration` to 5% of their length, so a 600 millisecond cooldown lasted 30. They now keep their full length.
- An `onError` that throws no longer leaves a button loading or a `BouncyExclusiveScope` locked. Its error is reported to Flutter instead.
- The default loading spinner now uses the button's text color. It took the color from outside the button, so it was dark, and hard to see, on dark buttons. Custom `loadingBuilder`, `successBuilder`, and `errorBuilder` content also gets the button's colors now.

### Documentation

- The README is now the full guide. Every feature has a plain-words explanation, when it helps, a code sample, its defaults, what you can change, and a screenshot and GIF, followed by a reference of every option and its default.
- The example app opens on a new Features tab, which shows every feature in the README's order. The README's images are recorded from it with `example/tool/make_gifs.sh`.

### Changed

- `BouncyButtonGroup` segments use checked semantics, as Flutter's `SegmentedButton` does, so screen readers also announce unselected ones. Tests that looked for a selected flag on a segment should check `isChecked`.
- The keyboard focus ring is 3 pixels wide instead of 2 in high contrast mode.

## [2.1.2] - 2026-11-02

- The Example tab on pub.dev now shows a one-screen tour of the main features, instead of the demo app's launcher. No code changes.

## [2.1.1] - 2026-11-02

- Rewrote the README: each feature is now explained in plain words with a short example, and the option tables moved to a reference section. No code changes.

## [2.1.0] - 2026-11-02

### Added

- `cooldown` on `BouncyButton` and `BouncyPressable`, which ignores presses for a while after the button is used, so a quick double tap doesn't run an action twice. For `onPressedAsync`, it starts once the button is ready again, and errors count too.
- `BouncyAsyncBuilder`, which adds double-tap protection and loading, success, and error states to any button, including Material and Cupertino ones. It needs no Material code and is also exported from `package:bouncy_button/pressable.dart`.
- `BouncyButtonController`, to press or reset a button from code and follow its status.
- `BouncyExclusiveScope.lockDuringLoading`, which lets only one async action below it run at a time.
- `BouncyButtonFeedback.minLoadingDuration`, so a very fast action doesn't flash the spinner.
- `BouncyButtonFeedback.loadingText`, shown beside the spinner and read by screen readers.
- `BouncyButton.tooltip`.
- A destructive tone: `BouncyButtonStyle.tone` with `BouncyButtonTone.destructive`, and a `BouncyButtonStyle.destructive` preset. It uses the theme's error colors with every fill.
- `BouncyButtonStyle.minTapTarget`, which enlarges the tap area of a small button without changing how it looks.
- `BouncyHapticFeedbackType` and `BouncyGradientExtension`, prefixed names that can't clash with other packages.

### Deprecated

- `HapticFeedbackType`, renamed `BouncyHapticFeedbackType`. The old name still works.
- `GradientExtension`, renamed `BouncyGradientExtension`. Implicit calls such as `gradient.scaleLightness(0.5)` are unaffected.

### Changed

- `BouncyButtonStatus` moved to the library's enums, so it is available without Material. Imports of `package:bouncy_button/bouncy_button.dart` are unaffected.

## [2.0.0] - 2026-11-02

### Breaking changes

- **Width:** a button with no `width` now sizes to its child, as the docs always said, instead of filling all available space. To keep a full-width button, set `width: double.infinity` or place it where the parent forces a width, such as inside `Expanded`.
- **Height:** `BouncyButtonStyle.height` is now a minimum, so the face grows instead of clipping large text. Circular buttons stay exactly this tall.
- **Dragging:** dragging a finger across the button and releasing no longer counts as a press. Press and release is now handled the same way as Material buttons: moving away cancels the press.
- **Colors:** with no colors set, the face now uses `colorScheme.primary` instead of `primaryColor`, and text and icons default to a contrasting color. A color set directly on the child still wins.
- **Long press only:** a button with `onLongPress` but no `onPressed` is now enabled, so it looks enabled and can take focus. It used to render as disabled and ignore the long press.
- **Nullable fields:** `BouncyButton.style`, `animation`, and `interaction` are now nullable, because null means "use the theme".
- `BouncyButtonStyle.flat` is 46 tall instead of 44, so it reaches the 48px minimum tap target with its elevation.
- `BouncyButtonAnimation.bouncy` has new values and now springs past its resting position on release.
- `bounce` animations now use `scaleAmount` and stay scaled while held. They used to return to full size during a long hold.
- `hslColor` now also paints the face when `backgroundColor` is null.
- Requires Flutter 3.27 or later. The old `>=3.10.0` constraint was never accurate, because Dart `^3.6.0` already required it.

### Fixed

- Quick taps now show the full press. Taps shorter than about 100ms used to show no movement at all.
- The button no longer throws inside a `Row` or other parent with unbounded width.
- `BouncyButtonTheme` now works. It was documented but never read by the widget.
- Enter and Space now activate a focused button, and a focus ring shows during keyboard navigation.
- Disabled buttons can no longer take focus.
- Screen readers now always announce a button, and no longer offer scroll actions on it. `semanticLabel` replaces the child's label instead of being read alongside it.
- The system "reduce motion" setting is now respected.
- `enableSplash: true` no longer removes the press animation and haptics from quick taps.
- `enableSplash: true` no longer throws with a `BorderRadiusDirectional`.
- Disabling a button while it is held no longer throws or leaves it stuck down.
- The button now stays down for the whole of a long press.
- Disabled gradients are now darkened as intended rather than made see-through, and the depth layer matches them.
- Changing `curve` at runtime now takes effect.
- The default colors no longer make the button invisible on dark themes.
- Animation frames no longer rebuild the button's contents or `builder`.
- `pub get` is far smaller: the package archive no longer includes the demo GIFs.

### Added

- `BouncyPressable`, which adds the press effect to any widget. It needs no Material code, and is also available on its own from `package:bouncy_button/pressable.dart`.
- Nested presses: pressing a button or pressable inside another leaves the outer one still.
- `BouncyExclusiveScope`, which allows only one press at a time below it.
- `BouncyButton.onPressedAsync`, which shows a loading state until the returned future completes, then success or an error. The button ignores presses meanwhile, so a form or payment can't be sent twice. Errors go to `onError`, or to `FlutterError.reportError`, and are never silently dropped.
- `BouncyButton.isLoading`, for loading managed outside the button.
- `BouncyButtonFeedback` to customize loading, success, and error, including the labels screen readers announce. Set it app-wide with `BouncyButtonTheme.defaultFeedback`.
- `BouncyButton.leading`, `trailing`, and `gap`, for icons beside the label.
- `BouncyButtonStyle.fill` with `BouncyButtonFill.filled`, `tonal`, `outlined`, and `ghost`, plus matching `tonal`, `outlined`, and `ghost` presets. Text meets the 4.5:1 contrast minimum in light and dark themes.
- `BouncyButtonStyle.fromSize` with `BouncyButtonSize.small`, `medium`, and `large`, which scale height, depth, padding, and text together. Every size is at least 48 pixels tall.
- `BouncyButtonStyle.textStyle` and `iconSize`.
- `BouncyButtonStyle.simple`, for quick setup from a color and size, and the `shadowLight` and `shadowDark` constants.
- `BouncyButtonColors.darken` and `lighten`.
- `BouncyButtonScope`, which themes buttons without the Material `Theme`, for apps using `package:material_ui`.
- `BouncyButtonTheme` value equality.
- `BouncyPressSpring` and `BouncyButtonAnimation.spring`, for spring physics. Pressing again mid-release reverses smoothly from wherever the button is, keeping its speed. Includes `snappy`, `bouncy`, and `gentle` springs and a `BouncyButtonAnimation.springy` preset. Also on `BouncyPressable.spring`.
- Hover lift: with a mouse, the face rises slightly while hovered. Set the height with `BouncyButtonInteraction.hoverLift`, or 0 to turn it off. Reduced motion turns it off.
- `BouncyButtonStyle.pressedBorderRadius`, which morphs the corners as the button is pressed, such as from a pill or circle to a rounded square.
- `BouncyButtonGroup` and `BouncyButtonSegment`, a row of connected buttons for choosing one option or several. Only the outer corners are rounded, on the correct sides in right-to-left layouts, and screen readers announce which segments are selected.
- `BouncyButtonFill.glass` and `BouncyButtonStyle.glass`, a translucent, blurred face with no depth. It turns solid when the system high contrast setting is on.
- Press sounds: `BouncyButtonInteraction.enableSound` plays the system click where the platform has one, and `onPressSound` plays your own. Also on `BouncyPressable`.
- `BouncyButton.tertiary`, using `BouncyButtonTheme.tertiaryStyle`.
- `BouncyButton.onTapDown`, `onTapUp`, `onTapCancel`, and `hitTestBehavior`.
- `BouncyButtonStyle.foregroundColor`.
- `BouncyButtonAnimation.reverseDuration` and `reverseCurve`.
- `BouncyButtonInteraction.hoverColor` and `focusColor`.
- Value equality for `BouncyButtonStyle`, `BouncyButtonAnimation`, and `BouncyButtonInteraction`.
- `GradientExtension.scaleLightness`.

### Deprecated

- `GradientExtension.scale`. `gradient.scale()` always called Flutter's own `Gradient.scale`, so this method never ran without explicit extension syntax. Use `scaleLightness`.

## [1.0.4] - 2025-08-15

- Improved documentation

## [1.0.3] - 2025-08-15

- Updated Readme file with png and gif

## [1.0.2] - 2025-08-15

- Minor changes in example app

## [1.0.1] - 2025-08-15

- Added Git Repository Info

## [1.0.0] - 2025-08-15

- Initial release
- 3D depth press effect with customizable elevation
- Multiple animation types (depth, scale, rotation, bounce, fade, slide)
- Extensive styling options with gradients and shadows
- Haptic feedback support
- Theme integration
- Predefined button styles (primary, secondary, flat, pill, circle)
- Color manipulation utilities
- Full accessibility support
- Comprehensive documentation and examples
