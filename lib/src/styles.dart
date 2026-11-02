import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
// ============================================================================
// lib/src/styles.dart
// ============================================================================

/// Configuration for button styling.
///
/// This class contains all the visual properties that can be customized
/// for a [BouncyButton].
@immutable
class BouncyButtonStyle {
  /// Creates a button style configuration.
  const BouncyButtonStyle({
    this.height = 60,
    this.width,
    this.elevation = 8,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledColor,
    this.hslColor,
    this.gradient,
    this.disabledGradient,
    this.shadow,
    this.shadows,
    this.borderRadius,
    this.border,
    this.shape = BoxShape.rectangle,
    this.padding,
    this.margin,
    this.shadowColor,
    this.shadowDarkness = 0.3,
    this.clipBehavior = Clip.none,
    this.opacity = 1.0,
    this.alignment,
    this.transform,
    this.transformAlignment,
    this.decoration,
    this.shadowDecoration,
  });

  /// The minimum height of the button face, excluding [elevation].
  ///
  /// The face grows past this when its content needs more room, such as with
  /// large system text sizes. Circular buttons are always exactly this tall.
  final double height;

  /// The width of the button.
  ///
  /// If null, the button sizes itself to its child, or fills its parent when
  /// the parent forces a width (for example inside [Expanded]). Use
  /// [double.infinity] to fill the available width.
  final double? width;

  /// The depth/elevation of the 3D effect.
  final double elevation;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The default color of text and icons inside the button.
  ///
  /// If null, a color that contrasts with the button's background is chosen.
  /// A color set directly on the child takes precedence.
  final Color? foregroundColor;

  /// The color of the button when disabled.
  final Color? disabledColor;

  /// HSL color for the button face and automatic shadow generation.
  ///
  /// Used for the face when [backgroundColor] is null.
  final HSLColor? hslColor;

  /// Gradient background for the button.
  final Gradient? gradient;

  /// Gradient for the disabled state.
  final Gradient? disabledGradient;

  /// Custom shadow for the button face.
  final BoxShadow? shadow;

  /// List of shadows for more complex shadow effects.
  final List<BoxShadow>? shadows;

  /// The border radius of the button.
  final BorderRadiusGeometry? borderRadius;

  /// Border decoration for the button.
  final BoxBorder? border;

  /// Shape of the button (rectangle or circle).
  final BoxShape shape;

  /// Padding inside the button.
  final EdgeInsetsGeometry? padding;

  /// Margin around the button.
  final EdgeInsetsGeometry? margin;

  /// Shadow color for the 3D depth effect.
  final Color? shadowColor;

  /// How much darker the shadow should be (0.0 - 1.0).
  final double shadowDarkness;

  /// Clip behavior for the button.
  final Clip clipBehavior;

  /// Opacity of the button (0.0 - 1.0).
  final double opacity;

  /// Alignment of the child within the button.
  final AlignmentGeometry? alignment;

  /// Transform to apply to the button.
  final Matrix4? transform;

  /// Origin of the transform.
  final AlignmentGeometry? transformAlignment;

  /// Decoration for the button face (advanced customization).
  final BoxDecoration? decoration;

  /// Decoration for the shadow/depth layer (advanced customization).
  final BoxDecoration? shadowDecoration;

  /// Creates a copy with modified fields.
  BouncyButtonStyle copyWith({
    double? height,
    double? width,
    double? elevation,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledColor,
    HSLColor? hslColor,
    Gradient? gradient,
    Gradient? disabledGradient,
    BoxShadow? shadow,
    List<BoxShadow>? shadows,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    BoxShape? shape,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? shadowColor,
    double? shadowDarkness,
    Clip? clipBehavior,
    double? opacity,
    AlignmentGeometry? alignment,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    BoxDecoration? decoration,
    BoxDecoration? shadowDecoration,
  }) {
    return BouncyButtonStyle(
      height: height ?? this.height,
      width: width ?? this.width,
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      disabledColor: disabledColor ?? this.disabledColor,
      hslColor: hslColor ?? this.hslColor,
      gradient: gradient ?? this.gradient,
      disabledGradient: disabledGradient ?? this.disabledGradient,
      shadow: shadow ?? this.shadow,
      shadows: shadows ?? this.shadows,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      shape: shape ?? this.shape,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowDarkness: shadowDarkness ?? this.shadowDarkness,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      opacity: opacity ?? this.opacity,
      alignment: alignment ?? this.alignment,
      transform: transform ?? this.transform,
      transformAlignment: transformAlignment ?? this.transformAlignment,
      decoration: decoration ?? this.decoration,
      shadowDecoration: shadowDecoration ?? this.shadowDecoration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BouncyButtonStyle &&
        other.height == height &&
        other.width == width &&
        other.elevation == elevation &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.disabledColor == disabledColor &&
        other.hslColor == hslColor &&
        other.gradient == gradient &&
        other.disabledGradient == disabledGradient &&
        other.shadow == shadow &&
        listEquals(other.shadows, shadows) &&
        other.borderRadius == borderRadius &&
        other.border == border &&
        other.shape == shape &&
        other.padding == padding &&
        other.margin == margin &&
        other.shadowColor == shadowColor &&
        other.shadowDarkness == shadowDarkness &&
        other.clipBehavior == clipBehavior &&
        other.opacity == opacity &&
        other.alignment == alignment &&
        other.transform == transform &&
        other.transformAlignment == transformAlignment &&
        other.decoration == decoration &&
        other.shadowDecoration == shadowDecoration;
  }

  @override
  int get hashCode => Object.hashAll([
        height,
        width,
        elevation,
        backgroundColor,
        foregroundColor,
        disabledColor,
        hslColor,
        gradient,
        disabledGradient,
        shadow,
        if (shadows != null) Object.hashAll(shadows!),
        borderRadius,
        border,
        shape,
        padding,
        margin,
        shadowColor,
        shadowDarkness,
        clipBehavior,
        opacity,
        alignment,
        transform,
        transformAlignment,
        decoration,
        shadowDecoration,
      ]);

  /// Primary button style with standard elevation and padding.
  static const BouncyButtonStyle primary = BouncyButtonStyle(
    height: 56,
    elevation: 8,
    shadowDarkness: 0.3,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );

  /// Secondary button style with reduced elevation.
  static const BouncyButtonStyle secondary = BouncyButtonStyle(
    height: 48,
    elevation: 6,
    shadowDarkness: 0.25,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  );

  /// Flat button style with minimal elevation.
  static const BouncyButtonStyle flat = BouncyButtonStyle(
    height: 46,
    elevation: 2,
    shadowDarkness: 0.15,
    borderRadius: BorderRadius.all(Radius.circular(6)),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  /// Pill-shaped button style with rounded edges.
  static const BouncyButtonStyle pill = BouncyButtonStyle(
    height: 48,
    elevation: 6,
    shadowDarkness: 0.3,
    borderRadius: BorderRadius.all(Radius.circular(24)),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );

  /// Circular button style for icon buttons.
  static const BouncyButtonStyle circle = BouncyButtonStyle(
    height: 56,
    width: 56,
    elevation: 8,
    shape: BoxShape.circle,
    shadowDarkness: 0.3,
    padding: EdgeInsets.all(12),
  );
}
