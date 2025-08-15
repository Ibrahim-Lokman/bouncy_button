import 'package:flutter/material.dart';
import 'enums.dart';
// ============================================================================
// lib/src/animations.dart
// ============================================================================

/// Configuration for button animations.
///
/// This class controls how the button animates when pressed.
class BouncyButtonAnimation {
  /// Creates an animation configuration.
  const BouncyButtonAnimation({
    this.duration = const Duration(milliseconds: 70),
    this.curve = Curves.easeInOut,
    this.type = BouncyButtonAnimationType.depth,
    this.scaleAmount = 0.95,
    this.rotationAngle = 0.03,
    this.animateOpacity = false,
  });

  /// Duration of the press animation.
  final Duration duration;

  /// The animation curve to use.
  final Curve curve;

  /// Type of animation effect.
  final BouncyButtonAnimationType type;

  /// Scale factor for scale animations (0.0 - 1.0).
  final double scaleAmount;

  /// Rotation angle for rotation animations (in radians).
  final double rotationAngle;

  /// Whether to animate opacity changes.
  final bool animateOpacity;

  /// Creates a copy with modified fields.
  BouncyButtonAnimation copyWith({
    Duration? duration,
    Curve? curve,
    BouncyButtonAnimationType? type,
    double? scaleAmount,
    double? rotationAngle,
    bool? animateOpacity,
  }) {
    return BouncyButtonAnimation(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      type: type ?? this.type,
      scaleAmount: scaleAmount ?? this.scaleAmount,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      animateOpacity: animateOpacity ?? this.animateOpacity,
    );
  }

  /// Quick animation preset with short duration.
  static const BouncyButtonAnimation quick = BouncyButtonAnimation(
    duration: Duration(milliseconds: 50),
    curve: Curves.easeOut,
  );

  /// Smooth animation preset with longer duration.
  static const BouncyButtonAnimation smooth = BouncyButtonAnimation(
    duration: Duration(milliseconds: 150),
    curve: Curves.easeInOutCubic,
  );

  /// Bouncy animation preset with elastic curve.
  static const BouncyButtonAnimation bouncy = BouncyButtonAnimation(
    duration: Duration(milliseconds: 200),
    curve: Curves.elasticOut,
    type: BouncyButtonAnimationType.bounce,
  );
}
