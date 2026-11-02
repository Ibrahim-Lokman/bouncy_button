// ============================================================================
// lib/src/enums.dart
// ============================================================================

/// Animation types for the bouncy button.
enum BouncyButtonAnimationType {
  /// 3D depth press effect (default).
  depth,

  /// Scale down effect.
  scale,

  /// Slight rotation effect.
  rotation,

  /// Bounce effect.
  bounce,

  /// Fade effect.
  fade,

  /// Slide effect.
  slide,
}

/// How a button's face is filled.
enum BouncyButtonFill {
  /// A solid face in the main color, for the most important action.
  filled,

  /// A softer face in a container color, for secondary actions.
  tonal,

  /// A surface-colored face with a colored border and text.
  outlined,

  /// No face or depth, only colored text, for the least prominent actions.
  ghost,

  /// A translucent, blurred face over whatever is behind it, with no depth.
  ///
  /// Blurring is costly, so avoid it in long lists. With the system high
  /// contrast setting on, the face is solid instead.
  glass,
}

/// Preset button sizes that scale height, depth, padding, and text together.
enum BouncyButtonSize {
  /// 44 tall with 4 of depth: a 48 pixel tap target.
  small,

  /// 48 tall with 6 of depth.
  medium,

  /// 56 tall with 8 of depth.
  large,
}

/// What an async button is showing.
enum BouncyButtonStatus {
  /// Ready to be pressed.
  idle,

  /// Waiting for the action to finish, or `isLoading` is true.
  loading,

  /// The action finished. Shown for `BouncyButtonFeedback.resultDuration`.
  success,

  /// The action threw. Shown for `BouncyButtonFeedback.resultDuration`.
  error,
}

/// The meaning of a button, which can change its colors.
enum BouncyButtonTone {
  /// No special meaning.
  normal,

  /// The action destroys or removes something, such as deleting a file. Uses
  /// the theme's error colors.
  destructive,
}

/// The old name of [BouncyHapticFeedbackType].
@Deprecated(
  'Use BouncyHapticFeedbackType instead. The old name could clash with other '
  'packages. Deprecated in 2.1.0.',
)
typedef HapticFeedbackType = BouncyHapticFeedbackType;

/// Haptic feedback types.
enum BouncyHapticFeedbackType {
  /// Light impact feedback.
  light,

  /// Medium impact feedback.
  medium,

  /// Heavy impact feedback.
  heavy,

  /// Selection click feedback.
  selection,

  /// Standard vibration.
  vibrate,
}
