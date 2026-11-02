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

/// Haptic feedback types.
enum HapticFeedbackType {
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
