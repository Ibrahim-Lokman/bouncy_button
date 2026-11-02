import 'package:flutter/material.dart';
// ============================================================================
// lib/src/utils.dart
// ============================================================================

/// Color adjustments for gradients.
extension BouncyGradientExtension on Gradient {
  /// Multiplies the lightness of each gradient color by [factor].
  Gradient scaleLightness(double factor) {
    final scaledColors = colors.map((color) {
      final hsl = HSLColor.fromColor(color);
      return hsl
          .withLightness(
            (hsl.lightness * factor).clamp(0.0, 1.0),
          )
          .toColor();
    }).toList();

    if (this is LinearGradient) {
      final lg = this as LinearGradient;
      return LinearGradient(
        colors: scaledColors,
        begin: lg.begin,
        end: lg.end,
        stops: lg.stops,
        tileMode: lg.tileMode,
        transform: lg.transform,
      );
    } else if (this is RadialGradient) {
      final rg = this as RadialGradient;
      return RadialGradient(
        colors: scaledColors,
        center: rg.center,
        radius: rg.radius,
        stops: rg.stops,
        tileMode: rg.tileMode,
        focal: rg.focal,
        focalRadius: rg.focalRadius,
        transform: rg.transform,
      );
    } else if (this is SweepGradient) {
      final sg = this as SweepGradient;
      return SweepGradient(
        colors: scaledColors,
        center: sg.center,
        startAngle: sg.startAngle,
        endAngle: sg.endAngle,
        stops: sg.stops,
        tileMode: sg.tileMode,
        transform: sg.transform,
      );
    }

    return this;
  }
}

/// The old name of [BouncyGradientExtension], kept for its deprecated
/// [scale] method.
@Deprecated(
  'Use BouncyGradientExtension instead. The old name could clash with other '
  'packages. Deprecated in 2.1.0.',
)
extension GradientExtension on Gradient {
  /// Multiplies the lightness of each gradient color by [factor].
  ///
  /// `gradient.scale(0.6)` always calls [Gradient.scale], which fades colors
  /// instead, so this method only runs with explicit extension syntax.
  @Deprecated('Use scaleLightness instead.')
  Gradient scale(double factor) =>
      BouncyGradientExtension(this).scaleLightness(factor);
}

/// Utility class for color manipulation.
class BouncyButtonColors {
  /// Creates a gradient from a single color.
  static LinearGradient gradientFromColor(
    Color color, {
    double spread = 0.2,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    final hsl = HSLColor.fromColor(color);
    final lighter = hsl
        .withLightness(
          (hsl.lightness + spread).clamp(0.0, 1.0),
        )
        .toColor();
    final darker = hsl
        .withLightness(
          (hsl.lightness - spread).clamp(0.0, 1.0),
        )
        .toColor();

    return LinearGradient(
      colors: [lighter, color, darker],
      begin: begin,
      end: end,
    );
  }

  /// Darkens [color] by lowering its HSL lightness by [amount], from 0 to 1.
  static Color darken(Color color, [double amount = 0.12]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Lightens [color] by raising its HSL lightness by [amount], from 0 to 1.
  static Color lighten(Color color, [double amount = 0.12]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Creates a complementary color.
  static Color complementary(Color color) {
    final hsl = HSLColor.fromColor(color);
    final complementaryHue = (hsl.hue + 180) % 360;
    return hsl.withHue(complementaryHue).toColor();
  }

  /// Creates an analogous color scheme.
  static List<Color> analogous(Color color, {int count = 3}) {
    final hsl = HSLColor.fromColor(color);
    final List<Color> colors = [];
    final step = 30.0 / count;

    for (int i = 0; i < count; i++) {
      final hue = (hsl.hue + (i - count ~/ 2) * step) % 360;
      colors.add(hsl.withHue(hue).toColor());
    }

    return colors;
  }

  /// Creates a triadic color scheme.
  static List<Color> triadic(Color color) {
    final hsl = HSLColor.fromColor(color);
    return [
      color,
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  /// Creates a tetradic color scheme.
  static List<Color> tetradic(Color color) {
    final hsl = HSLColor.fromColor(color);
    return [
      color,
      hsl.withHue((hsl.hue + 90) % 360).toColor(),
      hsl.withHue((hsl.hue + 180) % 360).toColor(),
      hsl.withHue((hsl.hue + 270) % 360).toColor(),
    ];
  }

  /// Creates a monochromatic color scheme.
  static List<Color> monochromatic(Color color, {int count = 5}) {
    final hsl = HSLColor.fromColor(color);
    final List<Color> colors = [];
    final step = 0.8 / count;

    for (int i = 0; i < count; i++) {
      final lightness = (0.2 + (i * step)).clamp(0.0, 1.0);
      colors.add(hsl.withLightness(lightness).toColor());
    }

    return colors;
  }
}
