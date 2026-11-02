import 'package:flutter/material.dart';
import 'enums.dart';
// ============================================================================
// lib/src/interactions.dart
// ============================================================================

/// Configuration for button interactions.
///
/// This class controls haptic feedback, splash effects, cursor behavior, and
/// the hover and keyboard focus highlights.
@immutable
class BouncyButtonInteraction {
  /// Creates an interaction configuration.
  const BouncyButtonInteraction({
    this.enableHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.light,
    this.cursor,
    this.enableSplash = false,
    this.splashColor,
    this.highlightColor,
    this.splashFactory,
    this.hoverColor,
    this.focusColor,
  });

  /// Whether to enable haptic feedback.
  final bool enableHapticFeedback;

  /// Type of haptic feedback.
  final HapticFeedbackType hapticFeedbackType;

  /// Mouse cursor when hovering over the button.
  final MouseCursor? cursor;

  /// Whether to show a ripple effect on tap.
  final bool enableSplash;

  /// Color of the splash effect.
  final Color? splashColor;

  /// Highlight color when pressed.
  final Color? highlightColor;

  /// Custom splash factory.
  final InteractiveInkFeatureFactory? splashFactory;

  /// Overlay color while a mouse hovers over the button.
  ///
  /// If null, a faint tint of the button's foreground color is used.
  final Color? hoverColor;

  /// Color of the ring shown when the button has keyboard focus.
  ///
  /// If null, the button's foreground color is used.
  final Color? focusColor;

  /// Creates a copy with modified fields.
  BouncyButtonInteraction copyWith({
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    MouseCursor? cursor,
    bool? enableSplash,
    Color? splashColor,
    Color? highlightColor,
    InteractiveInkFeatureFactory? splashFactory,
    Color? hoverColor,
    Color? focusColor,
  }) {
    return BouncyButtonInteraction(
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      hapticFeedbackType: hapticFeedbackType ?? this.hapticFeedbackType,
      cursor: cursor ?? this.cursor,
      enableSplash: enableSplash ?? this.enableSplash,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      splashFactory: splashFactory ?? this.splashFactory,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BouncyButtonInteraction &&
        other.enableHapticFeedback == enableHapticFeedback &&
        other.hapticFeedbackType == hapticFeedbackType &&
        other.cursor == cursor &&
        other.enableSplash == enableSplash &&
        other.splashColor == splashColor &&
        other.highlightColor == highlightColor &&
        other.splashFactory == splashFactory &&
        other.hoverColor == hoverColor &&
        other.focusColor == focusColor;
  }

  @override
  int get hashCode => Object.hash(
        enableHapticFeedback,
        hapticFeedbackType,
        cursor,
        enableSplash,
        splashColor,
        highlightColor,
        splashFactory,
        hoverColor,
        focusColor,
      );
}
