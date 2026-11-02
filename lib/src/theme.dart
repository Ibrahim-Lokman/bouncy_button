import 'package:flutter/material.dart';
import 'bouncy_button_widget.dart';
import 'styles.dart';
import 'animations.dart';
import 'interactions.dart';
import 'feedback.dart';
import 'scope.dart';
// ============================================================================
// lib/src/theme.dart
// ============================================================================

/// Theme extension for BouncyButton.
///
/// Allows defining app-wide button styles through the Material Theme system.
/// A style, animation, or interaction passed directly to a [BouncyButton]
/// replaces the themed value.
class BouncyButtonTheme extends ThemeExtension<BouncyButtonTheme> {
  /// Creates a button theme.
  const BouncyButtonTheme({
    this.primaryStyle,
    this.secondaryStyle,
    this.tertiaryStyle,
    this.defaultAnimation,
    this.defaultInteraction,
    this.defaultFeedback,
  });

  /// Style for [BouncyButton] and [BouncyButton.primary] when they are not
  /// given a style.
  final BouncyButtonStyle? primaryStyle;

  /// Style for [BouncyButton.secondary] when it is not given a style.
  final BouncyButtonStyle? secondaryStyle;

  /// Style for [BouncyButton.tertiary] when it is not given a style.
  final BouncyButtonStyle? tertiaryStyle;

  /// Default animation configuration.
  final BouncyButtonAnimation? defaultAnimation;

  /// Default interaction configuration.
  final BouncyButtonInteraction? defaultInteraction;

  /// Default loading, success, and error feedback for async buttons.
  final BouncyButtonFeedback? defaultFeedback;

  @override
  BouncyButtonTheme copyWith({
    BouncyButtonStyle? primaryStyle,
    BouncyButtonStyle? secondaryStyle,
    BouncyButtonStyle? tertiaryStyle,
    BouncyButtonAnimation? defaultAnimation,
    BouncyButtonInteraction? defaultInteraction,
    BouncyButtonFeedback? defaultFeedback,
  }) {
    return BouncyButtonTheme(
      primaryStyle: primaryStyle ?? this.primaryStyle,
      secondaryStyle: secondaryStyle ?? this.secondaryStyle,
      tertiaryStyle: tertiaryStyle ?? this.tertiaryStyle,
      defaultAnimation: defaultAnimation ?? this.defaultAnimation,
      defaultInteraction: defaultInteraction ?? this.defaultInteraction,
      defaultFeedback: defaultFeedback ?? this.defaultFeedback,
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

  /// Gets the button theme for [context]: the nearest [BouncyButtonScope],
  /// otherwise the extension in the Material [Theme].
  static BouncyButtonTheme? of(BuildContext context) {
    return BouncyButtonScope.maybeOf(context) ??
        Theme.of(context).extension<BouncyButtonTheme>();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BouncyButtonTheme &&
        other.primaryStyle == primaryStyle &&
        other.secondaryStyle == secondaryStyle &&
        other.tertiaryStyle == tertiaryStyle &&
        other.defaultAnimation == defaultAnimation &&
        other.defaultInteraction == defaultInteraction &&
        other.defaultFeedback == defaultFeedback;
  }

  @override
  int get hashCode => Object.hash(
        primaryStyle,
        secondaryStyle,
        tertiaryStyle,
        defaultAnimation,
        defaultInteraction,
        defaultFeedback,
      );
}
