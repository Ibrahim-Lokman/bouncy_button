## [2.0.0] - Unreleased

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
