import 'package:flutter/widgets.dart';

import 'animations.dart';
import 'enums.dart';

/// Applies the effect of a [BouncyButtonAnimationType] to [child].
class PressTransform extends StatelessWidget {
  /// Creates a press transform.
  const PressTransform({
    super.key,
    required this.animation,
    required this.animationValue,
    required this.reduceMotion,
    required this.child,
  });

  /// The configuration of the effect.
  final BouncyButtonAnimation animation;

  /// The press progress, from 0 at rest to 1 when fully pressed.
  final double animationValue;

  /// Whether to leave out the effect.
  final bool reduceMotion;

  /// The widget to transform.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion) {
      return child;
    }
    switch (animation.type) {
      case BouncyButtonAnimationType.scale:
      case BouncyButtonAnimationType.bounce:
        final scale = 1.0 - (animationValue * (1.0 - animation.scaleAmount));
        return Transform.scale(
          scale: scale,
          child: child,
        );

      case BouncyButtonAnimationType.rotation:
        return Transform.rotate(
          angle: animationValue * animation.rotationAngle,
          child: child,
        );

      case BouncyButtonAnimationType.fade:
        return Opacity(
          opacity: (1.0 - (animationValue * 0.2)).clamp(0.0, 1.0),
          child: child,
        );

      case BouncyButtonAnimationType.slide:
        return Transform.translate(
          offset: Offset(animationValue * 2, 0),
          child: child,
        );

      case BouncyButtonAnimationType.depth:
        return child;
    }
  }
}
