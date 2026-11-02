# Bouncy Button

A highly customizable Flutter button widget with engaging 3D depth effects, smooth animations, and extensive styling options. Create beautiful, interactive buttons that respond to user input with satisfying visual feedback.

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

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  bouncy_button: ^2.0.0
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

### Tap Callbacks

Both widgets accept `onTapDown`, `onTapUp`, `onTapCancel`, and `hitTestBehavior`. A button with only `onLongPress` stays enabled.

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

## Migrating to 2.0

- **Full-width buttons:** a button with no `width` now fits its child. Add `width: double.infinity` to any button that should fill its parent.
- **Dragging:** moving a finger away from the button now cancels the press, as with Material buttons. Dragging and releasing on the button no longer calls `onPressed`.
- **Text colors:** text and icons now default to a color that contrasts with the button. Set `foregroundColor` to choose your own.
- **Long press only:** a button with `onLongPress` but no `onPressed` is now enabled. Set `enabled: false` to disable it.

See the [changelog](CHANGELOG.md) for the full list.

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
