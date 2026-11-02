# Bouncy Button

[![pub package](https://img.shields.io/pub/v/bouncy_button.svg)](https://pub.dev/packages/bouncy_button)
[![CI](https://github.com/Ibrahim-Lokman/bouncy_button/actions/workflows/ci.yml/badge.svg)](https://github.com/Ibrahim-Lokman/bouncy_button/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Buttons people want to press.** Bouncy Button gives your Flutter app a tactile 3D button that sinks when tapped and springs back when released. It also handles the hard parts of real buttons for you: loading states, accidental double taps, and accessibility.

<p align="center">
  <img src="https://raw.githubusercontent.com/Ibrahim-Lokman/bouncy_button/main/gifs/gif_1.gif" alt="Bouncy buttons being pressed" width="300">
  &nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/Ibrahim-Lokman/bouncy_button/main/gifs/gif_2.gif" alt="Styled bouncy buttons" width="300">
</p>

## Why Bouncy Button

- **It feels real.** The button face sits on a darker layer, like a key on a keyboard, and sinks into it when pressed. Even the quickest tap shows the full press.
- **It's safe for real actions.** Give it a function that saves or pays, and it shows a spinner, then a tick or an error. It ignores extra taps while it works, so nothing is sent twice.
- **It works with what you already have.** Add the same press to any card or image, or add double-tap protection to the Material and Cupertino buttons you already use.
- **It's accessible out of the box.** Screen readers, keyboards, large text, and the "reduce motion" setting all work with no extra code.
- **It's light.** No dependencies beyond Flutter, and it runs on Android, iOS, web, macOS, Windows, and Linux.

## Getting started

Add the package:

```yaml
dependencies:
  bouncy_button: ^2.1.0
```

Then use it like any button:

```dart
import 'package:bouncy_button/bouncy_button.dart';

BouncyButton(
  onPressed: () => print('Pressed!'),
  child: const Text('Press me'),
)
```

With no style set, the button uses your app's theme colors and picks a readable text color, in both light and dark mode.

## Features

- [The 3D press](#the-3d-press)
- [A style for every action](#a-style-for-every-action)
- [Loading, success, and error](#loading-success-and-error)
- [No accidental double taps](#no-accidental-double-taps)
- [Protect the buttons you already have](#protect-the-buttons-you-already-have)
- [The bounce on any widget](#the-bounce-on-any-widget)
- [Button groups](#button-groups)
- [Motion that feels alive](#motion-that-feels-alive)
- [Built for everyone](#built-for-everyone)
- [Style your whole app at once](#style-your-whole-app-at-once)
- [More control](#more-control)

### The 3D press

Every button has two layers: the face you see, and a darker layer underneath that gives it depth. Pressing pushes the face down into that layer, and letting go lets it spring back up. You choose how deep it goes, its colors, and its shape.

```dart
BouncyButton(
  onPressed: () {},
  style: BouncyButtonStyle(
    backgroundColor: Colors.teal,
    elevation: 10, // How deep the press goes
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Text('Continue'),
)
```

Besides sinking, a button can also shrink, tilt, bounce, fade, or slide as it's pressed. Set `animation: BouncyButtonAnimation(type: BouncyButtonAnimationType.scale)` to try one.

### A style for every action

Most screens have one main action and a few smaller ones. Bouncy Button has a style for each, so the most important button stands out:

| Use it for | Style | What it looks like |
| --- | --- | --- |
| The main action, such as **Pay** | `BouncyButtonStyle.primary` | Solid color |
| Secondary actions, such as **Apply** | `BouncyButtonStyle.tonal` | Softer color |
| Minor actions, such as **Cancel** | `BouncyButtonStyle.outlined` or `ghost` | Outline only, or text only |
| Deleting something | `BouncyButtonStyle.destructive` | Your theme's error red |

```dart
BouncyButton(
  onPressed: deleteAccount,
  style: BouncyButtonStyle.destructive,
  leading: const Icon(Icons.delete_outline),
  child: const Text('Delete account'),
)
```

- **Sizes:** `BouncyButtonStyle.fromSize(BouncyButtonSize.small)`, `medium`, or `large` adjust height, depth, padding, and text together. Even the small size is easy to tap.
- **Icons:** `leading` and `trailing` put an icon before or after the label, on the correct side for right-to-left languages.
- **Quick setup:** `BouncyButtonStyle.simple(color: Colors.teal, width: 200)` takes just the values you need most.
- **Combining:** mix styles with `copyWith`, for example `BouncyButtonStyle.destructive.copyWith(fill: BouncyButtonFill.outlined)` for a red outlined button.

### Loading, success, and error

Saving, sending, or paying takes time. Use `onPressedAsync` instead of `onPressed`, and the button shows a spinner while your code runs. Then it shows a tick when it's done, or an error icon with a small shake if something went wrong. While it's busy, extra taps are ignored, so an order can't be placed twice.

```dart
BouncyButton(
  onPressedAsync: () => api.placeOrder(cart),
  onError: (error, stackTrace) => showMessage('Payment failed'),
  child: const Text('Pay'),
)
```

Adjust the details with `feedback`:

```dart
feedback: const BouncyButtonFeedback(
  loadingText: 'Paying…',                        // Shown next to the spinner
  minLoadingDuration: Duration(milliseconds: 400), // No flicker on fast networks
  resultDuration: Duration(seconds: 2),           // How long the tick stays
),
```

The button keeps its size while the content changes, so nothing around it jumps. If your code throws and you haven't set `onError`, the error is reported to Flutter instead of disappearing silently. If you track loading yourself, pass `isLoading: true`.

### No accidental double taps

A fast double tap normally runs your code twice, which can open the same page twice. Set a `cooldown`, and the button ignores taps for that long after each use:

```dart
BouncyButton(
  onPressed: () => Navigator.of(context).push(route),
  cooldown: const Duration(milliseconds: 600),
  child: const Text('Open'),
)
```

For `onPressedAsync`, the cooldown starts once the button is ready again.

### Protect the buttons you already have

You don't have to change your design to get these protections. `BouncyAsyncBuilder` wraps the buttons you already use, from Material, Cupertino, or your own design system:

```dart
BouncyAsyncBuilder(
  onPressed: () => api.placeOrder(cart),
  builder: (context, onPressed, status) => ElevatedButton(
    onPressed: onPressed,
    child: status == BouncyButtonStatus.loading
        ? const CircularProgressIndicator()
        : const Text('Pay'),
  ),
)
```

Repeat taps are blocked instantly, even two in the same frame, and keyboard focus is kept. Use `status` to show progress your own way.

### The bounce on any widget

`BouncyPressable` gives any widget, such as a product card, a photo, or a list item, the same satisfying press. It shrinks slightly while held and springs back on release.

```dart
BouncyPressable(
  onTap: () => openProduct(product),
  child: ProductCard(product),
)
```

When one pressable sits inside another, such as a heart button on a card, only the one you touch reacts. If you'd rather avoid Material imports, use `package:bouncy_button/pressable.dart`.

### Button groups

A row of connected buttons for picking one option, like Day, Week, or Month. Set `multiSelect: true` to allow several.

```dart
BouncyButtonGroup<String>(
  segments: const [
    BouncyButtonSegment(value: 'day', label: Text('Day')),
    BouncyButtonSegment(value: 'week', label: Text('Week')),
    BouncyButtonSegment(value: 'month', label: Text('Month')),
  ],
  selected: {view},
  onSelectionChanged: (selection) => setState(() => view = selection.first),
)
```

Screen readers announce which option is selected.

### Motion that feels alive

- **Springs:** with a spring, the button follows your finger naturally. Press again while it's still rising, and it smoothly turns around instead of restarting. Try `BouncyButtonAnimation(spring: BouncyPressSpring.bouncy)`, or the `snappy` and `gentle` springs.
- **Changing shape:** `pressedBorderRadius` changes the corners while pressed, for example from a pill to a rounded square.
- **Hover:** on desktop and web, the button rises slightly when the mouse is over it.

People who turn on "reduce motion" in their system settings get instant, still buttons instead.

### Built for everyone

These work automatically, with no extra code:

- **Screen readers** announce each button, and its loading, success, and error states.
- **Keyboards:** Tab moves between buttons, Enter or Space presses them, and a focus ring shows where you are.
- **Large text:** buttons grow to fit bigger system fonts instead of cutting words off.
- **Reduce motion** is respected.

Two options help further:

- `tooltip: 'Add to favorites'` explains a button that only has an icon, on hover, long press, and to screen readers.
- `BouncyButtonStyle(minTapTarget: 48)` makes a small button easier to hit without changing how it looks.

### Style your whole app at once

Set your button styles once in your theme, and every button follows them:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      BouncyButtonTheme(
        primaryStyle: BouncyButtonStyle(backgroundColor: Colors.indigo),
        defaultAnimation: BouncyButtonAnimation.smooth,
      ),
    ],
  ),
)
```

A style passed to a single button still wins. If your app uses Flutter's newer `material_ui` package, wrap your app in `BouncyButtonScope(theme: ...)` instead.

### More control

- **Press from code:** a `BouncyButtonController` can press a button, reset it, or tell you whether it's loading. This is useful for keyboard shortcuts or onboarding tours.
- **One action at a time:** `BouncyExclusiveScope(lockDuringLoading: true, child: ...)` stops two actions from running together, such as "Sign in with Google" and "Sign in with Apple".
- **Feedback:** choose a haptic, such as `BouncyHapticFeedbackType.medium`, or add a click sound with `enableSound: true`.
- **Glass:** `BouncyButtonStyle.glass` gives a frosted, see-through button for colorful backgrounds.
- **Gradients and custom content:** use a `gradient`, a full `decoration`, or a `builder` that knows when the button is pressed.

## Reference

The full API, with every option, is on [pub.dev](https://pub.dev/documentation/bouncy_button/latest/). These are the ones you'll reach for most.

### BouncyButtonStyle

| Option | What it does |
| --- | --- |
| `backgroundColor`, `foregroundColor` | Face color, and text and icon color |
| `fill` | `filled`, `tonal`, `outlined`, `ghost`, or `glass` |
| `tone` | `normal` or `destructive` |
| `height`, `width` | Minimum height, and width. Leave `width` empty to fit the label, or use `double.infinity` to fill the space |
| `elevation`, `shadowDarkness` | How deep the press goes, and how dark the layer underneath is |
| `borderRadius`, `pressedBorderRadius` | Corners at rest, and while pressed |
| `padding`, `textStyle`, `iconSize` | Inner spacing, text style, and icon size |
| `gradient`, `border`, `shadows` | Extra decoration |
| `minTapTarget` | Smallest tap area, such as 48 |

### BouncyButtonAnimation

| Option | What it does |
| --- | --- |
| `type` | `depth`, `scale`, `rotation`, `bounce`, `fade`, or `slide` |
| `duration`, `curve` | Speed and feel of the press |
| `reverseDuration`, `reverseCurve` | Speed and feel of the release |
| `spring` | Spring physics, which replaces duration and curves |

### BouncyButtonInteraction

| Option | What it does |
| --- | --- |
| `enableHapticFeedback`, `hapticFeedbackType` | Vibration on press |
| `enableSound`, `onPressSound` | System click, or your own sound |
| `enableSplash`, `splashColor` | Material ripple |
| `hoverColor`, `hoverLift`, `focusColor`, `cursor` | Mouse and keyboard highlights |

### BouncyButtonFeedback

| Option | What it does |
| --- | --- |
| `loadingBuilder`, `successBuilder`, `errorBuilder` | Your own loading, success, and error content |
| `loadingText` | Text next to the spinner |
| `showSuccess`, `showError`, `shakeOnError` | Which results to show |
| `resultDuration`, `minLoadingDuration` | How long results and loading stay visible |
| `loadingLabel`, `successLabel`, `errorLabel` | What screen readers say. Translate these for your app |

## Example app

The [example app](example/) shows every feature in action, including a small shop with a checkout that can succeed, fail, and retry. It runs on built-in sample data, so it needs no setup:

```bash
cd example
flutter run
```

## Upgrading

### From 1.x to 2.0

- **Width:** a button with no `width` now fits its label. Add `width: double.infinity` where it should fill the space.
- **Dragging:** sliding your finger off the button now cancels the press, like Material buttons.
- **Text color:** text now picks a color that's readable on the button. Set `foregroundColor` to choose your own.
- **Long press only:** a button with only `onLongPress` is now enabled. Set `enabled: false` to disable it.

See the [changelog](CHANGELOG.md) for everything else.

### Migration examples

#### Example A: a press effect on any widget

```dart
// Before
Bounceable(onTap: open, scaleFactor: 0.9, child: card)

// After
BouncyPressable(onTap: open, scaleFactor: 0.9, child: card)
```

The timing and callback options keep their names. The default `scaleFactor` is 0.95.

#### Example B: blocking repeat taps on an existing button

```dart
// Before
TapDebouncer(
  onTap: () => api.save(),
  cooldown: const Duration(seconds: 1),
  builder: (context, onTap) => ElevatedButton(onPressed: onTap, child: const Text('Save')),
)

// After
BouncyAsyncBuilder(
  onPressed: () => api.save(),
  cooldown: const Duration(seconds: 1),
  builder: (context, onPressed, status) => ElevatedButton(onPressed: onPressed, child: const Text('Save')),
)
```

To disable the button while it's busy, set `disableWhileBusy: true`.

#### Example C: a 3D button from a few values

```dart
// Before
AnimatedButton(
  onPressed: save,
  color: Colors.blue,
  width: 200,
  shadowDegree: ShadowDegree.dark,
  child: const Text('Save'),
)

// After
BouncyButton(
  onPressed: save,
  style: BouncyButtonStyle.simple(
    color: Colors.blue,
    width: 200,
    shadowDarkness: BouncyButtonStyle.shadowDark,
  ),
  child: const Text('Save'),
)
```

## Contributing

Bug reports, ideas, and pull requests are welcome. See the [contributing guide](CONTRIBUTING.md) to get started, and please follow the [code of conduct](CODE_OF_CONDUCT.md).

## License

MIT. See [LICENSE](LICENSE).

## Author

Made by **Ibrahim Lokman** in Bangladesh. Find me on [GitHub](https://github.com/Ibrahim-Lokman) or [LinkedIn](https://www.linkedin.com/in/ibrahim-lokman/), or [email me](mailto:ibrahimlokman.bd@gmail.com).

If Bouncy Button helps you, a ⭐ on [GitHub](https://github.com/Ibrahim-Lokman/bouncy_button) or a 👍 on [pub.dev](https://pub.dev/packages/bouncy_button) helps others find it.
