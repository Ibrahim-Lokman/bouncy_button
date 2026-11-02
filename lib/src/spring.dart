import 'package:flutter/foundation.dart';

/// Spring physics for the press animation.
///
/// A spring responds to the finger mid-animation: pressing again during a
/// release reverses smoothly from wherever the button is, carrying its speed,
/// instead of restarting a fixed curve. With a [dampingRatio] below 1, the
/// button overshoots on release before settling.
///
/// When a spring is set, the animation's duration and curves are not used.
/// Under the system "reduce motion" setting, the button moves instantly.
@immutable
class BouncyPressSpring {
  /// Creates a spring.
  const BouncyPressSpring({
    this.stiffness = 500,
    this.dampingRatio = 0.5,
    this.mass = 1,
  })  : assert(stiffness > 0, 'stiffness must be positive.'),
        assert(dampingRatio > 0, 'dampingRatio must be positive.'),
        assert(mass > 0, 'mass must be positive.');

  /// How strongly the spring pulls toward its target. Higher is faster.
  final double stiffness;

  /// How quickly motion dies away. Below 1 overshoots and bounces, 1 settles
  /// as fast as possible without overshoot, and above 1 is sluggish.
  final double dampingRatio;

  /// The mass on the spring. Higher feels heavier and slower.
  final double mass;

  /// Quick, with a hint of overshoot.
  static const BouncyPressSpring snappy = BouncyPressSpring(
    stiffness: 900,
    dampingRatio: 0.75,
  );

  /// A visible bounce on release.
  static const BouncyPressSpring bouncy = BouncyPressSpring(
    stiffness: 500,
    dampingRatio: 0.4,
  );

  /// Slow and soft, with no overshoot.
  static const BouncyPressSpring gentle = BouncyPressSpring(
    stiffness: 200,
    dampingRatio: 1,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BouncyPressSpring &&
        other.stiffness == stiffness &&
        other.dampingRatio == dampingRatio &&
        other.mass == mass;
  }

  @override
  int get hashCode => Object.hash(stiffness, dampingRatio, mass);

  @override
  String toString() => 'BouncyPressSpring(stiffness: $stiffness, '
      'dampingRatio: $dampingRatio, mass: $mass)';
}
