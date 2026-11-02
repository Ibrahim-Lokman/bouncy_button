import 'package:flutter/widgets.dart';

import 'enums.dart';
import 'press_core.dart';
import 'spring.dart';

/// Adds a bouncy press effect to any widget.
///
/// ```dart
/// BouncyPressable(
///   onTap: () => openProduct(product),
///   child: ProductCard(product),
/// )
/// ```
///
/// It handles keyboard activation, screen readers, reduced motion, and mouse
/// cursors, and needs no Material ancestor. For a complete button with a 3D
/// depth effect, use `BouncyButton`.
///
/// **Nesting:** when one pressable contains another, pressing the inner one
/// leaves the outer one still. Other controls inside, such as a `TextField`,
/// can't tell it they are pressed, so the outer one may dip while held on them.
class BouncyPressable extends StatelessWidget {
  /// Creates a pressable wrapper.
  const BouncyPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.enabled = true,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 120),
    this.reverseDuration,
    this.curve = Curves.easeOut,
    this.reverseCurve,
    this.spring,
    this.haptic,
    this.enableSound = false,
    this.onPressSound,
    this.cursor,
    this.hitTestBehavior,
    this.focusNode,
    this.autofocus = false,
    this.focusColor = const Color(0xFF1E88E5),
    this.focusBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.semanticLabel,
    this.semanticsButton = true,
  }) : assert(
          scaleFactor >= 0.0 && scaleFactor <= 1.0,
          'scaleFactor must be between 0.0 and 1.0.',
        );

  /// The widget to add the effect to.
  final Widget child;

  /// Called when the widget is tapped or activated.
  ///
  /// If this and [onLongPress] are both null, the effect is disabled.
  final VoidCallback? onTap;

  /// Called when the widget is long-pressed.
  final VoidCallback? onLongPress;

  /// Called when a press starts.
  final GestureTapDownCallback? onTapDown;

  /// Called when a press ends with a tap, before [onTap].
  final GestureTapUpCallback? onTapUp;

  /// Called when a press ends without a tap, such as when the finger moves
  /// away, a long press takes over, or the widget is disabled while held.
  final VoidCallback? onTapCancel;

  /// Whether the widget responds to input.
  final bool enabled;

  /// How far the widget shrinks when pressed, from 0.0 to 1.0.
  final double scaleFactor;

  /// Duration of the press.
  final Duration duration;

  /// Duration of the release. Defaults to [duration].
  final Duration? reverseDuration;

  /// Curve of the press.
  final Curve curve;

  /// Curve of the release. Defaults to [curve].
  final Curve? reverseCurve;

  /// Spring physics for the press. When set, [duration], [reverseDuration],
  /// [curve], and [reverseCurve] are not used.
  final BouncyPressSpring? spring;

  /// Haptic feedback for a press. Off by default.
  final HapticFeedbackType? haptic;

  /// Whether to play the system click sound on a press. The platform may
  /// have no such sound, and web plays nothing.
  final bool enableSound;

  /// Called on a press, to play a sound of your own.
  final VoidCallback? onPressSound;

  /// The mouse cursor. Defaults to a click cursor when enabled.
  final MouseCursor? cursor;

  /// How the widget behaves during hit testing. Defaults to
  /// [HitTestBehavior.opaque].
  final HitTestBehavior? hitTestBehavior;

  /// An optional focus node.
  final FocusNode? focusNode;

  /// Whether to request focus initially.
  final bool autofocus;

  /// The color of the ring shown when the widget has keyboard focus.
  final Color focusColor;

  /// The corners of the keyboard focus ring.
  final BorderRadius focusBorderRadius;

  /// The screen reader label, added to any labels from [child].
  final String? semanticLabel;

  /// Whether screen readers announce this as a single button.
  ///
  /// Set this to false when [child] contains other controls, so that they
  /// stay separately reachable.
  final bool semanticsButton;

  @override
  Widget build(BuildContext context) {
    return PressCore(
      onTap: onTap,
      onLongPress: onLongPress,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      enabled: enabled,
      duration: duration,
      reverseDuration: reverseDuration,
      curve: curve,
      reverseCurve: reverseCurve,
      spring: spring,
      haptic: haptic,
      enableSound: enableSound,
      onPressSound: onPressSound,
      cursor: cursor,
      hitTestBehavior: hitTestBehavior,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      semanticsButton: semanticsButton,
      builder: (context, press) {
        return AnimatedBuilder(
          animation: press.animation,
          builder: (context, child) {
            return Transform.scale(
              scale: press.reduceMotion
                  ? 1.0
                  : 1.0 - press.animation.value * (1.0 - scaleFactor),
              child: child,
            );
          },
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: press.isFocused
                  ? Border.all(color: focusColor, width: 2)
                  : null,
              borderRadius: press.isFocused ? focusBorderRadius : null,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
