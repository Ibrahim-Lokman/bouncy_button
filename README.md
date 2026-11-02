# Bouncy Button

A highly customizable Flutter button with a 3D press effect, async loading states, spring physics, and full accessibility, plus `BouncyPressable` to give any widget the same press.

## Features

✨ **3D Depth Effect** - Realistic button press with customizable elevation  
🎨 **Extensive Styling** - Gradients, shadows, borders, and custom decorations  
🎭 **Multiple Animations** - Depth, scale, rotation, bounce, fade, and slide effects  
📱 **Haptic Feedback** - Native platform haptic feedback support  
🎯 **Gesture Support** - Tap and long press, with a visible press on even the quickest tap  
♿ **Accessibility** - Screen reader support, keyboard activation, a focus ring, large text, and the system "reduce motion" setting  
🎨 **Theme Integration** - App-wide styles through `BouncyButtonTheme`, with legible default colors in light and dark themes  
🖥️ **Desktop and Web** - Hover highlight, mouse cursor, and keyboard navigation  
🧩 **Any Widget** - `BouncyPressable` adds the press effect to cards, images, and list items  
⏳ **Async Actions** - Loading, success, and error states, with double-submit protection  
🌀 **Springs and Shape** - Interruptible spring motion, hover lift, and corners that morph on press  
🎛️ **Sizes, Fills, and Groups** - Small to large sizes, filled to ghost fills, glass, icons, and connected button groups

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  bouncy_button: ^2.1.0
```

Then run:

```bash
flutter pub get
```

## Demo

<div align="center">
  <img src="https://raw.githubusercontent.com/Ibrahim-Lokman/bouncy_button/main/gifs/gif_1.gif" alt="Basic and Animated Button Demo" style="width: 100%; max-width: 400px;">
  <br><br>
  <img src="https://raw.githubusercontent.com/Ibrahim-Lokman/bouncy_button/main/gifs/gif_2.gif" alt="Styled and Interactive Button Demo" style="width: 100%; max-width: 400px;">
</div>

## Screenshots

### Light Theme

<img src="https://raw.githubusercontent.com/Ibrahim-Lokman/bouncy_button/main/screenshots/ss1.png" alt="Basic and Animated Buttons" width="300"> <img src="https://raw.githubusercontent.com/Ibrahim-Lokman/bouncy_button/main/screenshots/ss2.png" alt="Styled and Icon Buttons" width="300">

### Dark Theme

<img src="https://raw.githubusercontent.com/Ibrahim-Lokman/bouncy_button/main/screenshots/ss3.png" alt="Animated and Styled Buttons" width="300"> <img src="https://raw.githubusercontent.com/Ibrahim-Lokman/bouncy_button/main/screenshots/ss4.png" alt="Interactive and State Buttons" width="300">

## Usage

### Simple Usage

```dart
import 'package:bouncy_button/bouncy_button.dart';

BouncyButton(
  onPressed: () {
    print('Button pressed!');
  },
  child: Text('Click Me'),
)
```

### Sizing

A button sizes itself to its child, and fills its parent when the parent forces a width.

```dart
// Fits the label
BouncyButton(onPressed: () {}, child: Text('Fits')),

// Fills the available width
BouncyButton(
  onPressed: () {},
  style: BouncyButtonStyle(width: double.infinity),
  child: Text('Full width'),
),
```

`height` is a minimum, so the button grows when its content needs more room, such as with large system text sizes.

### Using Predefined Styles

```dart
// Primary style button
BouncyButton.primary(
  onPressed: () {},
  child: Text('Primary Button'),
)

// Secondary style button
BouncyButton.secondary(
  onPressed: () {},
  child: Text('Secondary Button'),
)

// Tertiary style button
BouncyButton.tertiary(
  onPressed: () {},
  child: Text('Tertiary Button'),
)
```

### Custom Styling

```dart
BouncyButton(
  onPressed: () {},
  style: BouncyButtonStyle(
    height: 60,
    elevation: 10,
    backgroundColor: Colors.purple,
    borderRadius: BorderRadius.circular(30),
    shadowDarkness: 0.4,
  ),
  child: Text('Custom Style'),
)
```

### With Gradient

```dart
BouncyButton(
  onPressed: () {},
  style: BouncyButtonStyle(
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: Text('Gradient Button'),
)
```

### Different Animation Types

```dart
// Scale animation
BouncyButton(
  onPressed: () {},
  animation: BouncyButtonAnimation(
    type: BouncyButtonAnimationType.scale,
    scaleAmount: 0.9,
  ),
  child: Text('Scale Animation'),
)

// Springs past its resting position on release
BouncyButton(
  onPressed: () {},
  animation: BouncyButtonAnimation.bouncy,
  child: Text('Bounce Animation'),
)
```

### With Haptic Feedback

```dart
BouncyButton(
  onPressed: () {},
  interaction: BouncyButtonInteraction(
    enableHapticFeedback: true,
    hapticFeedbackType: HapticFeedbackType.medium,
  ),
  child: Text('Haptic Feedback'),
)
```

### Icon Button

```dart
BouncyButton(
  onPressed: () {},
  style: BouncyButtonStyle.circle.copyWith(
    backgroundColor: Colors.red,
    width: 56,
    height: 56,
  ),
  child: Icon(Icons.favorite, color: Colors.white),
)
```

### Disabled State

```dart
BouncyButton(
  onPressed: null, // or enabled: false
  style: BouncyButtonStyle(
    disabledColor: Colors.grey,
  ),
  child: Text('Disabled Button'),
)
```

## Advanced Usage

### Custom Builder

```dart
BouncyButton(
  onPressed: () {},
  builder: (context, isPressed) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPressed ? Icons.star : Icons.star_border,
            color: isPressed ? Colors.yellow : Colors.white,
          ),
          SizedBox(width: 8),
          Text('Custom Builder'),
        ],
      ),
    );
  },
  child: Container(), // Child is ignored when builder is provided
)
```

### Theme Integration

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      BouncyButtonTheme(
        primaryStyle: BouncyButtonStyle(
          backgroundColor: Colors.blue,
          elevation: 8,
        ),
        defaultAnimation: BouncyButtonAnimation(
          duration: Duration(milliseconds: 100),
        ),
      ),
    ],
  ),
  home: MyHomePage(),
)
```

| Theme field          | Used by                                                  |
| -------------------- | -------------------------------------------------------- |
| `primaryStyle`       | `BouncyButton` and `BouncyButton.primary` with no style  |
| `secondaryStyle`     | `BouncyButton.secondary` with no style                   |
| `tertiaryStyle`      | `BouncyButton.tertiary` with no style                    |
| `defaultAnimation`   | Any button with no `animation`                           |
| `defaultInteraction` | Any button with no `interaction`                         |

A style passed directly to a button replaces the themed style entirely.

### Color Utilities

```dart
// Create gradient from single color
final gradient = BouncyButtonColors.gradientFromColor(
  Colors.blue,
  spread: 0.2,
);

// Get complementary color
final complementary = BouncyButtonColors.complementary(Colors.blue);

// Create color schemes
final analogous = BouncyButtonColors.analogous(Colors.blue);
final triadic = BouncyButtonColors.triadic(Colors.blue);
final monochromatic = BouncyButtonColors.monochromatic(Colors.blue);
```

### Icons, Sizes, and Fills

```dart
BouncyButton(
  onPressed: () {},
  style: BouncyButtonStyle.fromSize(BouncyButtonSize.large),
  leading: const Icon(Icons.add_shopping_cart),
  child: const Text('Add to cart'),
)
```

- **Icons:** `leading` and `trailing` sit either side of the label, `gap` apart, and swap sides in right-to-left layouts.
- **Sizes:** `BouncyButtonStyle.fromSize` scales height, depth, padding, and text together. `small` is still 48 pixels tall in total, the minimum tap target size.
- **Fills:** `filled`, `tonal`, `outlined`, and `ghost`, from most to least prominent. Use the `BouncyButtonStyle.tonal`, `outlined`, and `ghost` presets, or set `fill` yourself. For outlined and ghost buttons, `backgroundColor` sets the text and border color.

For quick setup, `BouncyButtonStyle.simple` takes the most common values:

```dart
BouncyButtonStyle.simple(
  color: Colors.teal,
  width: 200,
  shadowDarkness: BouncyButtonStyle.shadowDark,
)
```

### Choosing a Style

Show which action matters most through style, not size. Apple's [guidelines](https://developer.apple.com/design/human-interface-guidelines/buttons) also advise no more than one or two prominent buttons per screen.

| Action | Style |
| --- | --- |
| The main action, such as Pay | `BouncyButtonStyle.primary` (filled) |
| Secondary actions, such as Apply | `BouncyButtonStyle.tonal` |
| Minor actions, such as Cancel | `BouncyButtonStyle.outlined` or `ghost` |
| Deleting or removing something | `BouncyButtonStyle.destructive` |

`BouncyButtonStyle.destructive` uses the theme's error colors, and works with any fill:

```dart
BouncyButton(
  onPressed: deleteAccount,
  style: BouncyButtonStyle.destructive.copyWith(fill: BouncyButtonFill.outlined),
  child: const Text('Delete account'),
)
```

`BouncyButton.secondary` and `.tertiary` are filled too, and differ from the primary button only in size. Prefer the fills above for new code.

### Button Groups

`BouncyButtonGroup` is a row of connected buttons for choosing one option, or several with `multiSelect: true`:

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

Selected segments are filled and the rest tonal. Change them with `style` and `selectedStyle`. For icon-only segments, set `semanticLabel` so screen readers can name them.

### Glass and Sound

- **Glass:** `BouncyButtonStyle.glass` gives a translucent, blurred face over whatever is behind it. It has no depth, and turns solid when the system high contrast setting is on. Blurring is costly, so avoid it in long lists.
- **Sound:** `BouncyButtonInteraction(enableSound: true)` plays the system click on each press. The platform may have no such sound, the device's sound settings can silence it, and web plays nothing. For a sound that plays everywhere, pass `onPressSound` and play your own with an audio package.

### Async Actions

`onPressedAsync` shows a spinner until the returned future completes, then a check mark, or an error icon with a shake if it throws. The button ignores presses until it's ready again, so a form or payment can't be sent twice:

```dart
BouncyButton(
  onPressedAsync: () => api.placeOrder(cart),
  onError: (error, stackTrace) => showError(error),
  child: const Text('Pay'),
)
```

Use either `onPressed` or `onPressedAsync`, not both. Customize the states with `feedback`:

```dart
BouncyButton(
  onPressedAsync: save,
  feedback: BouncyButtonFeedback(
    successBuilder: (context) => const Text('Saved'),
    resultDuration: const Duration(seconds: 2),
    loadingLabel: 'Enregistrement', // Read by screen readers
  ),
  child: const Text('Save'),
)
```

If loading is managed elsewhere, pass `isLoading: true` instead. Errors without an `onError` handler go to `FlutterError.reportError`, so they are never silently lost.

Two more `feedback` options:

- `loadingText: 'Saving…'` shows text beside the spinner, which screen readers also read. The button keeps its size, so longer text is cut off.
- `minLoadingDuration: Duration(milliseconds: 400)` keeps loading on screen for at least that long, so a very fast action doesn't flash the spinner.

### Preventing Double Taps

A quick double tap on a plain `onPressed` runs it twice, which can open the same page twice. Set `cooldown` to ignore presses for a while after the button is used:

```dart
BouncyButton(
  onPressed: () => Navigator.of(context).push(route),
  cooldown: const Duration(milliseconds: 600),
  child: const Text('Open'),
)
```

For `onPressedAsync`, the cooldown starts once the button is ready again, after any success or error, and errors count too. `BouncyPressable` takes a `cooldown` as well.

### Protecting Any Button

`BouncyAsyncBuilder` brings the same protection and states to buttons you already use, including Material, Cupertino, and your own:

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

While the action runs, the callback ignores presses, even two in the same frame. It stays non-null, so the button keeps its keyboard focus. Set `disableWhileBusy: true` to receive `null` instead, which makes most buttons look disabled but drops focus. It takes `cooldown`, `controller`, and `feedback` timings, and needs no Material code.

### Controlling a Button from Code

```dart
final controller = BouncyButtonController();

BouncyButton(controller: controller, onPressedAsync: save, child: const Text('Save'))

await controller.press(); // Runs the action with its press animation
controller.reset();       // Back to idle, ignoring a late result
controller.status;        // idle, loading, success, or error
```

The controller is a `ChangeNotifier`, so you can listen for status changes. It works with `BouncyAsyncBuilder` too.

### Springs and Shape

A spring makes the press respond to the finger: pressing again mid-release reverses smoothly from wherever the button is, keeping its speed. Below a damping ratio of 1, it bounces as it settles.

```dart
BouncyButton(
  onPressed: () {},
  animation: const BouncyButtonAnimation(spring: BouncyPressSpring.bouncy),
  style: BouncyButtonStyle.pill.copyWith(
    pressedBorderRadius: BorderRadius.circular(8), // Pill to rounded square
  ),
  child: const Text('Play'),
)
```

- **Springs:** use `BouncyPressSpring.snappy`, `bouncy`, or `gentle`, or set `stiffness`, `dampingRatio`, and `mass` yourself. A spring replaces the duration and curves. `BouncyButtonAnimation.springy` is a ready-made preset.
- **Shape:** `pressedBorderRadius` morphs the corners during the press. A circle button starts as a circle.
- **Hover:** with a mouse, the face rises 2 pixels while hovered. Change it with `BouncyButtonInteraction.hoverLift`, or set 0 to turn it off.

Reduced motion turns off springs, hover lift, and the error shake: the button moves instantly.

### Press Effect on Any Widget

`BouncyPressable` adds a press-and-shrink effect to any widget, with the same keyboard, screen reader, and reduced-motion support as `BouncyButton`:

```dart
BouncyPressable(
  onTap: () => openProduct(product),
  scaleFactor: 0.95,
  child: ProductCard(product),
)
```

When pressables are nested, pressing the inner one leaves the outer one still. For a card containing its own buttons, set `semanticsButton: false` so screen readers can still reach those buttons.

`BouncyPressable` needs no Material code. To keep Material out of your imports, use `package:bouncy_button/pressable.dart`.

### One Press at a Time

Flutter tracks each finger separately, so two fingers can press two buttons at once. To allow only one press at a time, wrap part of the app in `BouncyExclusiveScope`:

```dart
MaterialApp(
  builder: (context, child) => BouncyExclusiveScope(child: child!),
)
```

Inside the scope, a press that starts while another button is held is ignored. Keyboard and screen reader activation are not affected.

To let only one async action run at a time, such as two sign-in buttons, set `lockDuringLoading`. While one is loading, the other async buttons in the scope are disabled:

```dart
BouncyExclusiveScope(
  lockDuringLoading: true,
  child: Column(children: [googleSignInButton, appleSignInButton]),
)
```

### Tooltips and Tap Targets

- **Tooltip:** `BouncyButton(tooltip: 'Add to favorites')` shows on hover or long press, and screen readers read it once. Use it for buttons with only an icon.
- **Tap target:** a button drawn smaller than 48 pixels is hard to tap. `BouncyButtonStyle(minTapTarget: 48)` enlarges the tap area without changing the look. It adds space around the button.

### Tap Callbacks

Both widgets accept `onTapDown`, `onTapUp`, `onTapCancel`, and `hitTestBehavior`. A button with only `onLongPress` stays enabled.

### Apps Using material_ui

Flutter is moving Material into the separate `material_ui` package, whose `Theme` is a different class from the SDK's. A `BouncyButtonTheme` in a `material_ui` theme's extensions won't reach the buttons. Use `BouncyButtonScope` instead:

```dart
BouncyButtonScope(
  theme: const BouncyButtonTheme(
    primaryStyle: BouncyButtonStyle(backgroundColor: Colors.teal),
  ),
  child: child,
)
```

Default colors still come from the SDK's `Theme`. See Flutter's [migration guide](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui) for passing your theme to packages that haven't migrated.

## Customization Options

### BouncyButtonStyle Properties

| Property          | Type                    | Description                     |
| ----------------- | ----------------------- | ------------------------------- |
| `height`          | `double`                | Minimum face height (default: 60) |
| `width`           | `double?`               | Button width (null = auto-size) |
| `elevation`       | `double`                | 3D depth effect (default: 8)    |
| `backgroundColor` | `Color?`                | Background color                |
| `foregroundColor` | `Color?`                | Default text and icon color     |
| `gradient`        | `Gradient?`             | Gradient background             |
| `borderRadius`    | `BorderRadiusGeometry?` | Corner radius                   |
| `shadowDarkness`  | `double`                | Shadow darkness (0.0-1.0)       |
| `padding`         | `EdgeInsetsGeometry?`   | Internal padding                |
| `border`          | `BoxBorder?`            | Border decoration               |
| `fill`            | `BouncyButtonFill`      | filled, tonal, outlined, ghost, or glass (default: filled) |
| `textStyle`       | `TextStyle?`            | Default text style              |
| `iconSize`        | `double?`               | Default icon size               |
| `pressedBorderRadius` | `BorderRadiusGeometry?` | Corners while fully pressed |
| `tone`            | `BouncyButtonTone`      | normal or destructive (default: normal) |
| `minTapTarget`    | `double?`               | Smallest tap area, such as 48   |

### BouncyButtonAnimation Properties

| Property        | Type                        | Description               |
| --------------- | --------------------------- | ------------------------- |
| `duration`      | `Duration`                  | Animation duration        |
| `reverseDuration` | `Duration?`               | Release duration          |
| `curve`         | `Curve`                     | Animation curve           |
| `reverseCurve`  | `Curve?`                    | Release curve             |
| `type`          | `BouncyButtonAnimationType` | Animation type            |
| `scaleAmount`   | `double`                    | Scale factor (0.0-1.0)    |
| `rotationAngle` | `double`                    | Rotation angle in radians |
| `spring`        | `BouncyPressSpring?`        | Spring physics, replacing duration and curves |

### BouncyButtonInteraction Properties

| Property               | Type                 | Description             |
| ---------------------- | -------------------- | ----------------------- |
| `enableHapticFeedback` | `bool`               | Enable haptic feedback  |
| `hapticFeedbackType`   | `HapticFeedbackType` | Type of haptic feedback |
| `enableSplash`         | `bool`               | Enable splash effect    |
| `splashColor`          | `Color?`             | Splash color            |
| `cursor`               | `MouseCursor?`       | Mouse cursor on hover   |
| `hoverColor`           | `Color?`             | Overlay color on hover  |
| `focusColor`           | `Color?`             | Keyboard focus ring     |
| `hoverLift`            | `double`             | Rise on mouse hover (default: 2) |
| `enableSound`          | `bool`               | Play the system click   |
| `onPressSound`         | `VoidCallback?`      | Play your own sound     |

## Migrating to 2.0

- **Full-width buttons:** a button with no `width` now fits its child. Add `width: double.infinity` to any button that should fill its parent.
- **Dragging:** moving a finger away from the button now cancels the press, as with Material buttons. Dragging and releasing on the button no longer calls `onPressed`.
- **Text colors:** text and icons now default to a color that contrasts with the button. Set `foregroundColor` to choose your own.
- **Long press only:** a button with `onLongPress` but no `onPressed` is now enabled. Set `enabled: false` to disable it.

See the [changelog](CHANGELOG.md) for the full list.

## Coming from Another Package

### From flutter_bounceable

`BouncyPressable` takes the same callback and timing names:

```dart
// flutter_bounceable
Bounceable(onTap: open, scaleFactor: 0.9, child: card)

// bouncy_button
BouncyPressable(onTap: open, scaleFactor: 0.9, child: card)
```

- `duration`, `reverseDuration`, `curve`, `reverseCurve`, `onTapDown`, `onTapUp`, `onTapCancel`, `onLongPress`, and `hitTestBehavior` work the same way.
- The default `scaleFactor` is 0.95 rather than 0.8. Set `scaleFactor: 0.8` for the old look.
- Nested pressables no longer both bounce, and setting changes apply on hot reload.
- To stop two simultaneous taps both firing, wrap the area in `BouncyExclusiveScope`.
- Keyboard activation, screen readers, and reduced motion work without any setup.

### From tap_debouncer

`tap_debouncer` passes your button a callback that is null while busy. `BouncyAsyncBuilder` does the same job, and adds success and error states, error reporting, and keyboard focus that isn't lost:

```dart
// tap_debouncer
TapDebouncer(
  onTap: () => api.save(),
  cooldown: const Duration(seconds: 1),
  builder: (context, onTap) => ElevatedButton(onPressed: onTap, child: const Text('Save')),
)

// bouncy_button
BouncyAsyncBuilder(
  onPressed: () => api.save(),
  cooldown: const Duration(seconds: 1),
  builder: (context, onPressed, status) => ElevatedButton(onPressed: onPressed, child: const Text('Save')),
)
```

- `waitBuilder`: use `status` in your builder instead, or `BouncyButton` with `feedback.loadingBuilder`.
- **Disabled look:** for buttons that look disabled while busy, as with `tap_debouncer`, set `disableWhileBusy: true`.
- **Errors:** an error still gets the cooldown, and is sent to `onError` or reported, rather than being lost.

### From animated_button

```dart
// animated_button
AnimatedButton(
  onPressed: save,
  color: Colors.blue,
  width: 200,
  shadowDegree: ShadowDegree.dark,
  child: const Text('Save'),
)

// bouncy_button
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

- `ShadowDegree.light` and `dark` match `BouncyButtonStyle.shadowLight` and `shadowDark`, and `darken()` is `BouncyButtonColors.darken`.
- Leave out `width` to size the button to its label, or use `double.infinity` to fill the space.
- `onPressed` runs once per tap. A cancelled press never calls it.

## Examples

The [example](example/) app demonstrates every feature, including a mock store with loading, error, and retry states. It runs entirely on mock data, so it needs no setup.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Ibrahim Lokman**

- 🌐 GitHub: [@Ibrahim-Lokman](https://github.com/Ibrahim-Lokman)
- 💼 LinkedIn: [ibrahim-lokman](https://www.linkedin.com/in/ibrahim-lokman/)
- 📧 Email: ibrahimlokman.bd@gmail.com
- 📍 Location: Bangladesh (GMT+6)

## Support

If you find this package useful, please consider:

- ⭐ Giving it a star on [GitHub](https://github.com/Ibrahim-Lokman/bouncy_button)
- 👍 Liking it on [pub.dev](https://pub.dev/packages/bouncy_button)
- 🐛 Reporting issues on the [issue tracker](https://github.com/Ibrahim-Lokman/bouncy_button/issues)

---

_Built with ❤️ in Bangladesh_
