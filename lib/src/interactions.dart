import 'package:flutter/material.dart';
import 'enums.dart';
// ============================================================================
// lib/src/interactions.dart
// ============================================================================

/// Configuration for button interactions.
///
/// This class controls haptic feedback, splash effects, and cursor behavior.
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

  /// Creates a copy with modified fields.
  BouncyButtonInteraction copyWith({
    bool? enableHapticFeedback,
    HapticFeedbackType? hapticFeedbackType,
    MouseCursor? cursor,
    bool? enableSplash,
    Color? splashColor,
    Color? highlightColor,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    return BouncyButtonInteraction(
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      hapticFeedbackType: hapticFeedbackType ?? this.hapticFeedbackType,
      cursor: cursor ?? this.cursor,
      enableSplash: enableSplash ?? this.enableSplash,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      splashFactory: splashFactory ?? this.splashFactory,
    );
  }
}
