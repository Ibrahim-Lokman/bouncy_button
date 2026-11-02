import 'package:flutter/material.dart';
import 'styles.dart';
import 'animations.dart';
import 'interactions.dart';
import 'press_core.dart';
import 'press_transform.dart';
import 'theme.dart';
import 'utils.dart';

enum _Variant { standard, primary, secondary, tertiary }

/// A highly customizable button widget with engaging 3D depth effects,
/// smooth animations, and extensive styling options.
///
/// The [BouncyButton] creates beautiful, interactive buttons that respond
/// to user input with satisfying visual feedback. It features a 3D depth
/// effect that makes the button appear to be pressed into the screen.
///
/// Example:
/// ```dart
/// BouncyButton(
///   onPressed: () {
///     print('Button pressed!');
///   },
///   style: BouncyButtonStyle(
///     backgroundColor: Colors.blue,
///     elevation: 8,
///   ),
///   child: Text('Click Me'),
/// )
/// ```
class BouncyButton extends StatefulWidget {
  /// Creates a bouncy button.
  const BouncyButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.hitTestBehavior,
    this.style,
    this.animation,
    this.interaction,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.builder,
  }) : _variant = _Variant.standard;

  /// Creates a primary style bouncy button.
  ///
  /// Uses [style] if provided, then [BouncyButtonTheme.primaryStyle], then
  /// [BouncyButtonStyle.primary].
  const BouncyButton.primary({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.hitTestBehavior,
    this.style,
    this.animation,
    this.interaction,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.builder,
  }) : _variant = _Variant.primary;

  /// Creates a secondary style bouncy button.
  ///
  /// Uses [style] if provided, then [BouncyButtonTheme.secondaryStyle], then
  /// [BouncyButtonStyle.secondary].
  const BouncyButton.secondary({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.hitTestBehavior,
    this.style,
    this.animation,
    this.interaction,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.builder,
  }) : _variant = _Variant.secondary;

  /// Creates a tertiary style bouncy button.
  ///
  /// Uses [style] if provided, then [BouncyButtonTheme.tertiaryStyle], then
  /// [BouncyButtonStyle.flat].
  const BouncyButton.tertiary({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.hitTestBehavior,
    this.style,
    this.animation,
    this.interaction,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.builder,
  }) : _variant = _Variant.tertiary;

  final _Variant _variant;

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget or an [Icon] widget.
  final Widget child;

  /// Called when the button is tapped or otherwise activated.
  ///
  /// If this and [onLongPress] are both null, the button is disabled.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// Called when a press starts.
  final GestureTapDownCallback? onTapDown;

  /// Called when a press ends with a tap, before [onPressed].
  final GestureTapUpCallback? onTapUp;

  /// Called when a press ends without a tap, such as when the finger moves
  /// away, a long press takes over, or the button is disabled while held.
  final VoidCallback? onTapCancel;

  /// How the button behaves during hit testing. Defaults to
  /// [HitTestBehavior.opaque].
  final HitTestBehavior? hitTestBehavior;

  /// Styling configuration for the button.
  ///
  /// Controls visual aspects like colors, elevation, borders, etc. If null,
  /// the matching style from [BouncyButtonTheme] is used.
  final BouncyButtonStyle? style;

  /// Animation configuration for the button.
  ///
  /// Controls animation duration, curve, and type. If null,
  /// [BouncyButtonTheme.defaultAnimation] is used.
  final BouncyButtonAnimation? animation;

  /// Interaction configuration for the button.
  ///
  /// Controls haptic feedback, splash effects, and cursor behavior. If null,
  /// [BouncyButtonTheme.defaultInteraction] is used.
  final BouncyButtonInteraction? interaction;

  /// Whether the button is enabled.
  ///
  /// If false, the button will not respond to touch events.
  final bool enabled;

  /// An optional focus node to use as the focus node for this widget.
  final FocusNode? focusNode;

  /// Whether this button should be focused initially.
  final bool autofocus;

  /// Semantic label for the button.
  ///
  /// This is used by screen readers for accessibility. When set, it replaces
  /// the label that would otherwise be read from [child].
  final String? semanticLabel;

  /// Custom widget builder for advanced use cases.
  ///
  /// If provided, this builder will be used instead of the default
  /// button content. The builder receives the current build context
  /// and a boolean indicating whether the button is pressed.
  final Widget Function(BuildContext, bool isPressed)? builder;

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton> {
  bool get _isEnabled =>
      widget.enabled &&
      (widget.onPressed != null || widget.onLongPress != null);

  BouncyButtonStyle get _style {
    final theme = BouncyButtonTheme.of(context);
    return widget.style ??
        switch (widget._variant) {
          _Variant.standard => theme?.primaryStyle ?? const BouncyButtonStyle(),
          _Variant.primary => theme?.primaryStyle ?? BouncyButtonStyle.primary,
          _Variant.secondary =>
            theme?.secondaryStyle ?? BouncyButtonStyle.secondary,
          _Variant.tertiary => theme?.tertiaryStyle ?? BouncyButtonStyle.flat,
        };
  }

  BouncyButtonAnimation get _animationConfig =>
      widget.animation ??
      BouncyButtonTheme.of(context)?.defaultAnimation ??
      const BouncyButtonAnimation();

  BouncyButtonInteraction get _interaction =>
      widget.interaction ??
      BouncyButtonTheme.of(context)?.defaultInteraction ??
      const BouncyButtonInteraction();

  MouseCursor _cursor(BouncyButtonInteraction interaction) {
    return interaction.cursor ??
        (_isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic);
  }

  Gradient? _faceGradient(BouncyButtonStyle style) {
    if (_isEnabled) {
      return style.gradient;
    }
    return style.disabledGradient ?? style.gradient?.scaleLightness(0.6);
  }

  Color _faceColor(BuildContext context, BouncyButtonStyle style) {
    if (!_isEnabled) {
      return style.disabledColor ?? Colors.grey;
    }
    return style.backgroundColor ??
        style.hslColor?.toColor() ??
        Theme.of(context).colorScheme.primary;
  }

  /// The color that most represents the button face, or null if unknown.
  Color? _faceBaseColor(BuildContext context, BouncyButtonStyle style) {
    final decoration = style.decoration;
    if (decoration != null) {
      return decoration.color ??
          (decoration.gradient?.colors.isNotEmpty ?? false
              ? decoration.gradient!.colors.first
              : null);
    }
    final gradient = _faceGradient(style);
    if (gradient != null && gradient.colors.isNotEmpty) {
      return gradient.colors.first;
    }
    return _faceColor(context, style);
  }

  Color? _foregroundColor(BuildContext context, BouncyButtonStyle style) {
    if (style.foregroundColor != null) {
      return style.foregroundColor;
    }
    final base = _faceBaseColor(context, style);
    if (base == null) {
      return null;
    }
    final scheme = Theme.of(context).colorScheme;
    if (base == scheme.primary) {
      return scheme.onPrimary;
    }
    return ThemeData.estimateBrightnessForColor(base) == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Color _depthColor(BuildContext context, BouncyButtonStyle style) {
    if (style.shadowColor != null) {
      return style.shadowColor!;
    }
    final base = _faceBaseColor(context, style) ?? _faceColor(context, style);
    // Dark themes use a pastel primary color, which turns neon when only its
    // HSL lightness is lowered.
    if (base == Theme.of(context).colorScheme.primary) {
      return Color.lerp(
        base,
        Colors.black,
        (style.shadowDarkness * 1.5).clamp(0.0, 1.0),
      )!;
    }
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness((hsl.lightness - style.shadowDarkness).clamp(0.0, 1.0))
        .toColor();
  }

  BorderRadiusGeometry? _borderRadius(BouncyButtonStyle style) {
    return style.shape == BoxShape.circle
        ? null
        : style.borderRadius ?? BorderRadius.circular(12);
  }

  BoxDecoration _faceDecoration(BuildContext context, BouncyButtonStyle style) {
    if (style.decoration != null) {
      return style.decoration!;
    }
    final gradient = _faceGradient(style);
    return BoxDecoration(
      gradient: gradient,
      color: gradient == null ? _faceColor(context, style) : null,
      borderRadius: _borderRadius(style),
      shape: style.shape,
      border: style.border,
      boxShadow:
          style.shadows ?? (style.shadow != null ? [style.shadow!] : null),
    );
  }

  BoxDecoration _shadowDecoration(
    BuildContext context,
    BouncyButtonStyle style,
  ) {
    return style.shadowDecoration ??
        BoxDecoration(
          color: _depthColor(context, style),
          borderRadius: _borderRadius(style),
          shape: style.shape,
        );
  }

  /// The hover tint and keyboard focus ring, painted over the face.
  BoxDecoration _highlightDecoration(
    BouncyButtonStyle style,
    BouncyButtonInteraction interaction,
    Color? foreground,
    PressCoreData press,
  ) {
    final fallback = foreground ?? Colors.black;
    final shape = style.decoration?.shape ?? style.shape;
    return BoxDecoration(
      color: press.isHovered
          ? interaction.hoverColor ?? fallback.withAlpha(20)
          : null,
      border: press.isFocused
          ? Border.all(color: interaction.focusColor ?? fallback, width: 2)
          : null,
      borderRadius: shape == BoxShape.circle
          ? null
          : style.decoration?.borderRadius ?? _borderRadius(style),
      shape: shape,
    );
  }

  Widget _buildContent(
    BuildContext context,
    BouncyButtonStyle style,
    PressCoreData press,
  ) {
    final builder = widget.builder;
    if (builder != null) {
      return builder(context, press.isPressed);
    }
    return Padding(
      padding: style.padding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: style.alignment ?? Alignment.center,
        widthFactor: 1,
        heightFactor: 1,
        child: widget.child,
      ),
    );
  }

  Widget _buildInk(
    BouncyButtonStyle style,
    BouncyButtonInteraction interaction,
    PressCoreData press,
    Widget child,
  ) {
    if (!interaction.enableSplash) {
      return child;
    }
    final enabled = press.isEnabled;
    final isCircle = style.shape == BoxShape.circle;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: enabled ? press.handleTap : null,
        onTapDown: enabled ? press.handleTapDown : null,
        onTapUp: enabled ? press.handleTapUp : null,
        onTapCancel: enabled ? press.handleTapCancel : null,
        splashColor: interaction.splashColor,
        highlightColor: interaction.highlightColor,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: interaction.splashFactory,
        mouseCursor: _cursor(interaction),
        canRequestFocus: false,
        excludeFromSemantics: true,
        customBorder: isCircle ? const CircleBorder() : null,
        borderRadius: isCircle
            ? null
            : _borderRadius(style)!.resolve(Directionality.of(context)),
        child: child,
      ),
    );
  }

  Widget _buildFace(
    BuildContext context,
    BouncyButtonStyle style,
    BouncyButtonInteraction interaction,
    PressCoreData press,
  ) {
    final foreground = _foregroundColor(context, style);
    Widget content = _buildContent(context, style, press);
    if (foreground != null) {
      content = IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground),
          child: content,
        ),
      );
    }
    final isCircle = style.shape == BoxShape.circle;
    return ConstrainedBox(
      constraints: isCircle
          ? BoxConstraints.tightFor(height: style.height)
          : BoxConstraints(minHeight: style.height),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: _highlightDecoration(
          style,
          interaction,
          foreground,
          press,
        ),
        child: Container(
          decoration: _faceDecoration(context, style),
          clipBehavior: style.clipBehavior,
          child: _buildInk(style, interaction, press, content),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    BouncyButtonStyle style,
    BouncyButtonInteraction interaction,
    BouncyButtonAnimation animationConfig,
    PressCoreData press,
  ) {
    final enabled = press.isEnabled;
    final reduceMotion = press.reduceMotion;
    // Built outside the AnimatedBuilder so that animation frames only move the
    // face instead of rebuilding its contents.
    final shadow = Positioned(
      top: style.elevation,
      bottom: 0,
      left: 0,
      right: 0,
      child: DecoratedBox(decoration: _shadowDecoration(context, style)),
    );
    final face = _buildFace(context, style, interaction, press);

    Widget content = AnimatedBuilder(
      animation: press.animation,
      builder: (context, _) {
        return PressTransform(
          animation: animationConfig,
          animationValue: press.animation.value,
          reduceMotion: reduceMotion,
          child: Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.none,
            children: [
              shadow,
              Padding(
                padding: EdgeInsets.only(bottom: style.elevation),
                child: Transform.translate(
                  offset: Offset(0, style.elevation * press.animation.value),
                  child: face,
                ),
              ),
            ],
          ),
        );
      },
    );

    final width =
        style.width ?? (style.shape == BoxShape.circle ? style.height : null);
    if (width != null) {
      content = SizedBox(width: width, child: content);
    }

    if (animationConfig.animateOpacity) {
      content = AnimatedOpacity(
        opacity: enabled ? style.opacity : style.opacity * 0.6,
        duration: reduceMotion ? Duration.zero : animationConfig.duration,
        child: content,
      );
    } else if (style.opacity < 1.0) {
      content = Opacity(opacity: style.opacity, child: content);
    }

    if (style.transform != null) {
      content = Transform(
        transform: style.transform!,
        alignment: style.transformAlignment,
        child: content,
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final interaction = _interaction;
    final animation = _animationConfig;

    Widget button = PressCore(
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTapDown,
      onTapUp: widget.onTapUp,
      onTapCancel: widget.onTapCancel,
      enabled: widget.enabled,
      duration: animation.duration,
      reverseDuration: animation.reverseDuration,
      curve: animation.curve,
      reverseCurve: animation.reverseCurve,
      haptic: interaction.enableHapticFeedback
          ? interaction.hapticFeedbackType
          : null,
      cursor: _cursor(interaction),
      hitTestBehavior: widget.hitTestBehavior,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      labelReplacesChildSemantics: true,
      builder: (context, press) =>
          _buildBody(context, style, interaction, animation, press),
    );

    if (style.margin != null) {
      button = Padding(padding: style.margin!, child: button);
    }
    return button;
  }
}
