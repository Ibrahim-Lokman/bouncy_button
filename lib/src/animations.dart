import 'package:flutter/material.dart';
import 'enums.dart';
// ============================================================================
// lib/src/animations.dart
// ============================================================================

/// Configuration for button animations.
///
/// This class controls how the button animates when pressed.
@immutable
class BouncyButtonAnimation {
  /// Creates an animation configuration.
  const BouncyButtonAnimation({
    this.duration = const Duration(milliseconds: 70),
    this.reverseDuration,
    this.curve = Curves.easeInOut,
    this.reverseCurve,
    this.type = BouncyButtonAnimationType.depth,
    this.scaleAmount = 0.95,
    this.rotationAngle = 0.03,
    this.animateOpacity = false,
  });

  /// Duration of the press animation.
  final Duration duration;

  /// Duration of the release animation. Defaults to [duration].
  final Duration? reverseDuration;

  /// The animation curve to use.
  final Curve curve;

  /// The curve of the release animation. Defaults to [curve].
  ///
  /// A curve that overshoots, such as [Curves.elasticIn], makes the button
  /// spring past its resting position on release.
  final Curve? reverseCurve;

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
    Duration? reverseDuration,
    Curve? curve,
    Curve? reverseCurve,
    BouncyButtonAnimationType? type,
    double? scaleAmount,
    double? rotationAngle,
    bool? animateOpacity,
  }) {
    return BouncyButtonAnimation(
      duration: duration ?? this.duration,
      reverseDuration: reverseDuration ?? this.reverseDuration,
      curve: curve ?? this.curve,
      reverseCurve: reverseCurve ?? this.reverseCurve,
      type: type ?? this.type,
      scaleAmount: scaleAmount ?? this.scaleAmount,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      animateOpacity: animateOpacity ?? this.animateOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BouncyButtonAnimation &&
        other.duration == duration &&
        other.reverseDuration == reverseDuration &&
        other.curve == curve &&
        other.reverseCurve == reverseCurve &&
        other.type == type &&
        other.scaleAmount == scaleAmount &&
        other.rotationAngle == rotationAngle &&
        other.animateOpacity == animateOpacity;
  }

  @override
  int get hashCode => Object.hash(
        duration,
        reverseDuration,
        curve,
        reverseCurve,
        type,
        scaleAmount,
        rotationAngle,
        animateOpacity,
      );

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

  /// Bouncy animation preset that springs past its resting position on release.
  static const BouncyButtonAnimation bouncy = BouncyButtonAnimation(
    duration: Duration(milliseconds: 90),
    reverseDuration: Duration(milliseconds: 450),
    curve: Curves.easeOut,
    reverseCurve: Curves.elasticIn,
    type: BouncyButtonAnimationType.bounce,
  );
}
