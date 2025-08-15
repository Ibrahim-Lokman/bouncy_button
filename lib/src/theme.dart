import 'package:flutter/material.dart';
import 'styles.dart';
import 'animations.dart';
import 'interactions.dart';
// ============================================================================
// lib/src/theme.dart
// ============================================================================

/// Theme extension for BouncyButton.
///
/// Allows defining app-wide button styles through the Material Theme system.
class BouncyButtonTheme extends ThemeExtension<BouncyButtonTheme> {
  /// Creates a button theme.
  const BouncyButtonTheme({
    this.primaryStyle,
    this.secondaryStyle,
    this.tertiaryStyle,
    this.defaultAnimation,
    this.defaultInteraction,
  });

  /// Primary button style.
  final BouncyButtonStyle? primaryStyle;

  /// Secondary button style.
  final BouncyButtonStyle? secondaryStyle;

  /// Tertiary button style.
  final BouncyButtonStyle? tertiaryStyle;

  /// Default animation configuration.
  final BouncyButtonAnimation? defaultAnimation;

  /// Default interaction configuration.
  final BouncyButtonInteraction? defaultInteraction;

  @override
  BouncyButtonTheme copyWith({
    BouncyButtonStyle? primaryStyle,
    BouncyButtonStyle? secondaryStyle,
    BouncyButtonStyle? tertiaryStyle,
    BouncyButtonAnimation? defaultAnimation,
    BouncyButtonInteraction? defaultInteraction,
  }) {
    return BouncyButtonTheme(
      primaryStyle: primaryStyle ?? this.primaryStyle,
      secondaryStyle: secondaryStyle ?? this.secondaryStyle,
      tertiaryStyle: tertiaryStyle ?? this.tertiaryStyle,
      defaultAnimation: defaultAnimation ?? this.defaultAnimation,
      defaultInteraction: defaultInteraction ?? this.defaultInteraction,
    );
  }

  @override
  BouncyButtonTheme lerp(ThemeExtension<BouncyButtonTheme>? other, double t) {
    if (other is! BouncyButtonTheme) {
      return this;
    }

    // For simplicity, we're not interpolating styles here
    // In a production app, you might want to implement proper lerping
    return t < 0.5 ? this : other;
  }

  /// Gets the button theme from the current context.
  static BouncyButtonTheme? of(BuildContext context) {
    return Theme.of(context).extension<BouncyButtonTheme>();
  }
}
