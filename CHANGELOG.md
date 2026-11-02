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
