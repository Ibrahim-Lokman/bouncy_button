import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'styles.dart';
import 'animations.dart';
import 'interactions.dart';
import 'enums.dart';

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
  /// Creates a secondary style bouncy button.
  ///
  /// This factory constructor creates a button with predefined
  /// secondary styling that can be further customized.
  factory BouncyButton.secondary({
    Key? key,
    required Widget child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    BouncyButtonStyle? style,
    BouncyButtonAnimation? animation,
    BouncyButtonInteraction? interaction,
    bool enabled = true,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    Widget Function(BuildContext, bool)? builder,
  }) {
    return BouncyButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: style ?? BouncyButtonStyle.secondary,
      animation: animation ?? const BouncyButtonAnimation(),
      interaction: interaction ?? const BouncyButtonInteraction(),
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      builder: builder,
      child: child,
    );
  }

  /// Creates a primary style bouncy button.
  ///
  /// This factory constructor creates a button with predefined
  /// primary styling that can be further customized.
  factory BouncyButton.primary({
    Key? key,
    required Widget child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    BouncyButtonStyle? style,
    BouncyButtonAnimation? animation,
    BouncyButtonInteraction? interaction,
    bool enabled = true,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    Widget Function(BuildContext, bool)? builder,
  }) {
    return BouncyButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: style ?? BouncyButtonStyle.primary,
      animation: animation ?? const BouncyButtonAnimation(),
      interaction: interaction ?? const BouncyButtonInteraction(),
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      builder: builder,
      child: child,
    );
  }

  /// Creates a bouncy button.
  const BouncyButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.style = const BouncyButtonStyle(),
    this.animation = const BouncyButtonAnimation(),
    this.interaction = const BouncyButtonInteraction(),
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.builder,
  });

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget or an [Icon] widget.
  final Widget child;

  /// Called when the button is tapped or otherwise activated.
  ///
  /// If this is null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// Styling configuration for the button.
  ///
  /// Controls visual aspects like colors, elevation, borders, etc.
  final BouncyButtonStyle style;

  /// Animation configuration for the button.
  ///
  /// Controls animation duration, curve, and type.
  final BouncyButtonAnimation animation;

  /// Interaction configuration for the button.
  ///
  /// Controls haptic feedback, splash effects, and cursor behavior.
  final BouncyButtonInteraction interaction;

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
  /// This is used by screen readers for accessibility.
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

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late final _AnimationManager _animationManager;
  late final _InteractionHandler _interactionHandler;
  late final _StyleManager _styleManager;

  final GlobalKey _buttonKey = GlobalKey();
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationManager = _AnimationManager(
      vsync: this,
      animation: widget.animation,
    );
    _interactionHandler = _InteractionHandler(
      interaction: widget.interaction,
      onPressStateChanged: _onPressStateChanged,
    );
    _styleManager = _StyleManager(style: widget.style);
  }

  @override
  void didUpdateWidget(BouncyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _animationManager.updateAnimation(widget.animation);
    }
    if (oldWidget.interaction != widget.interaction) {
      _interactionHandler.updateInteraction(widget.interaction);
    }
    if (oldWidget.style != widget.style) {
      _styleManager.updateStyle(widget.style);
    }
  }

  @override
  void dispose() {
    _animationManager.dispose();
    super.dispose();
  }

  void _onPressStateChanged(bool isPressed) {
    setState(() => _isPressed = isPressed);
    if (isPressed) {
      _animationManager.forward();
    } else {
      _animationManager.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool effectiveEnabled = widget.enabled && widget.onPressed != null;

    Widget buttonContent = _ButtonBuilder(
      buttonKey: _buttonKey,
      widget: widget,
      animationManager: _animationManager,
      interactionHandler: _interactionHandler,
      styleManager: _styleManager,
      isPressed: _isPressed,
      isHovered: _isHovered,
      effectiveEnabled: effectiveEnabled,
      onHoverChanged: (isHovered) => setState(() => _isHovered = isHovered),
      onPressed: widget.onPressed,
      onLongPress: widget.onLongPress,
    ).build(context);

    if (widget.semanticLabel != null) {
      buttonContent = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: effectiveEnabled,
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}

/// Manages animations for the button
class _AnimationManager {
  _AnimationManager({
    required this.vsync,
    required this.animation,
  }) {
    _initializeAnimation();
  }
  late AnimationController _controller;
  late Animation<double> _animation;
  final TickerProvider vsync;
  BouncyButtonAnimation animation;

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: animation.duration,
      vsync: vsync,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: animation.curve,
      ),
    );
  }

  void updateAnimation(BouncyButtonAnimation newAnimation) {
    animation = newAnimation;
    _controller.duration = newAnimation.duration;
  }

  void forward() => _controller.forward();
  void reverse() => _controller.reverse();

  Animation<double> get value => _animation;

  void dispose() {
    _controller.dispose();
  }
}

/// Handles user interactions
class _InteractionHandler {
  _InteractionHandler({
    required this.interaction,
    required this.onPressStateChanged,
  });
  BouncyButtonInteraction interaction;
  final Function(bool) onPressStateChanged;

  void updateInteraction(BouncyButtonInteraction newInteraction) {
    interaction = newInteraction;
  }

  void handleTapDown(TapDownDetails details) {
    onPressStateChanged(true);
    if (interaction.enableHapticFeedback) {
      _provideHapticFeedback();
    }
  }

  void handleTapUp(TapUpDetails details) {
    onPressStateChanged(false);
  }

  void handleTapCancel() {
    onPressStateChanged(false);
  }

  void handlePanUpdate(
    DragUpdateDetails details,
    GlobalKey buttonKey,
    bool isPressed,
  ) {
    final RenderBox? renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(details.globalPosition);
      final buttonRect = Rect.fromLTWH(
        0,
        0,
        renderBox.size.width,
        renderBox.size.height,
      );

      if (!buttonRect.contains(localPosition) && isPressed) {
        onPressStateChanged(false);
      } else if (buttonRect.contains(localPosition) && !isPressed) {
        onPressStateChanged(true);
      }
    }
  }

  void handlePanEnd(
    DragEndDetails details,
    bool isPressed,
    VoidCallback? onPressed,
  ) {
    if (isPressed) {
      onPressStateChanged(false);
      onPressed?.call();
    }
  }

  void _provideHapticFeedback() {
    switch (interaction.hapticFeedbackType) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  MouseCursor getCursor(bool effectiveEnabled) {
    return interaction.cursor ??
        (effectiveEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic);
  }
}

/// Manages styling for the button
class _StyleManager {
  _StyleManager({required this.style});
  BouncyButtonStyle style;

  void updateStyle(BouncyButtonStyle newStyle) {
    style = newStyle;
  }

  Color getShadowColor(BuildContext context, bool effectiveEnabled) {
    if (style.shadowColor != null) {
      return style.shadowColor!;
    }

    Color baseColor;
    if (style.hslColor != null) {
      final hslDark = style.hslColor!.withLightness(
        (style.hslColor!.lightness - style.shadowDarkness).clamp(0.0, 1.0),
      );
      return hslDark.toColor();
    } else if (style.gradient != null && style.gradient!.colors.isNotEmpty) {
      baseColor = effectiveEnabled
          ? style.gradient!.colors.first
          : style.disabledGradient?.colors.first ?? Colors.grey;
    } else {
      baseColor = effectiveEnabled
          ? style.backgroundColor ?? Theme.of(context).primaryColor
          : style.disabledColor ?? Colors.grey;
    }

    final hsl = HSLColor.fromColor(baseColor);
    final hslDark = hsl.withLightness(
      (hsl.lightness - style.shadowDarkness).clamp(0.0, 1.0),
    );
    return hslDark.toColor();
  }

  BoxDecoration buildButtonDecoration(
    BuildContext context,
    bool effectiveEnabled,
  ) {
    if (style.decoration != null) {
      return style.decoration!;
    }

    final BorderRadiusGeometry? effectiveBorderRadius =
        style.shape == BoxShape.circle
            ? null
            : style.borderRadius ?? BorderRadius.circular(12);

    return BoxDecoration(
      gradient: effectiveEnabled
          ? style.gradient
          : style.disabledGradient ?? style.gradient?.scale(0.6),
      color: style.gradient == null
          ? (effectiveEnabled
              ? style.backgroundColor ?? Theme.of(context).primaryColor
              : style.disabledColor ?? Colors.grey)
          : null,
      borderRadius: effectiveBorderRadius,
      shape: style.shape,
      border: style.border,
      boxShadow:
          style.shadows ?? (style.shadow != null ? [style.shadow!] : null),
    );
  }

  BoxDecoration buildShadowDecoration(
    BuildContext context,
    bool effectiveEnabled,
  ) {
    if (style.shadowDecoration != null) {
      return style.shadowDecoration!;
    }

    final Color shadowColor = getShadowColor(context, effectiveEnabled);
    final BorderRadiusGeometry? effectiveBorderRadius =
        style.shape == BoxShape.circle
            ? null
            : style.borderRadius ?? BorderRadius.circular(12);

    return BoxDecoration(
      color: shadowColor,
      borderRadius: effectiveBorderRadius,
      shape: style.shape,
    );
  }
}

/// Builds the button widget
class _ButtonBuilder {
  const _ButtonBuilder({
    required this.buttonKey,
    required this.widget,
    required this.animationManager,
    required this.interactionHandler,
    required this.styleManager,
    required this.isPressed,
    required this.isHovered,
    required this.effectiveEnabled,
    required this.onHoverChanged,
    required this.onPressed,
    required this.onLongPress,
  });
  final GlobalKey buttonKey;
  final BouncyButton widget;
  final _AnimationManager animationManager;
  final _InteractionHandler interactionHandler;
  final _StyleManager styleManager;
  final bool isPressed;
  final bool isHovered;
  final bool effectiveEnabled;
  final Function(bool) onHoverChanged;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  Widget build(BuildContext context) {
    return Container(
      margin: widget.style.margin,
      child: MouseRegion(
        cursor: interactionHandler.getCursor(effectiveEnabled),
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        child: Focus(
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          child: GestureDetector(
            key: buttonKey,
            onTapDown: effectiveEnabled
                ? (details) => interactionHandler.handleTapDown(details)
                : null,
            onTapUp: effectiveEnabled
                ? (details) {
                    interactionHandler.handleTapUp(details);
                    onPressed?.call();
                  }
                : null,
            onTapCancel: effectiveEnabled
                ? () => interactionHandler.handleTapCancel()
                : null,
            onLongPress: effectiveEnabled ? onLongPress : null,
            onPanUpdate: effectiveEnabled
                ? (details) => interactionHandler.handlePanUpdate(
                      details,
                      buttonKey,
                      isPressed,
                    )
                : null,
            onPanEnd: effectiveEnabled
                ? (details) => interactionHandler.handlePanEnd(
                      details,
                      isPressed,
                      onPressed,
                    )
                : null,
            child: AnimatedBuilder(
              animation: animationManager.value,
              builder: (context, child) {
                return _buildAnimatedContent(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(BuildContext context) {
    final double depth =
        widget.style.elevation * (1 - animationManager.value.value);

    Widget content = SizedBox(
      width: widget.style.width,
      height: widget.style.height + widget.style.elevation,
      child: Stack(
        children: [
          // Shadow/depth layer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: widget.style.height,
              decoration:
                  styleManager.buildShadowDecoration(context, effectiveEnabled),
            ),
          ),
          // Button face
          AnimatedPositioned(
            duration: widget.animation.duration,
            curve: widget.animation.curve,
            bottom: depth,
            left: 0,
            right: 0,
            child: Container(
              height: widget.style.height,
              width: widget.style.width,
              decoration:
                  styleManager.buildButtonDecoration(context, effectiveEnabled),
              clipBehavior: widget.style.clipBehavior,
              child: _buildButtonContent(context),
            ),
          ),
        ],
      ),
    );

    // Apply animation transformations
    content = _AnimationTransformer(
      animation: widget.animation,
      animationValue: animationManager.value.value,
      child: content,
    );

    // Apply opacity
    if (widget.animation.animateOpacity) {
      content = AnimatedOpacity(
        opacity: effectiveEnabled
            ? widget.style.opacity
            : widget.style.opacity * 0.6,
        duration: widget.animation.duration,
        child: content,
      );
    } else if (widget.style.opacity < 1.0) {
      content = Opacity(
        opacity: widget.style.opacity,
        child: content,
      );
    }

    // Apply custom transform
    if (widget.style.transform != null) {
      content = Transform(
        transform: widget.style.transform!,
        alignment: widget.style.transformAlignment,
        child: content,
      );
    }

    return content;
  }

  Widget _buildButtonContent(BuildContext context) {
    Widget content = widget.builder?.call(context, isPressed) ??
        Container(
          padding: widget.style.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          alignment: widget.style.alignment ?? Alignment.center,
          child: widget.child,
        );

    if (widget.interaction.enableSplash) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveEnabled ? onPressed : null,
          splashColor: widget.interaction.splashColor,
          highlightColor: widget.interaction.highlightColor,
          splashFactory: widget.interaction.splashFactory,
          borderRadius: widget.style.shape == BoxShape.circle
              ? null
              : widget.style.borderRadius as BorderRadius? ??
                  BorderRadius.circular(12),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Applies animation transformations to the button
class _AnimationTransformer extends StatelessWidget {
  const _AnimationTransformer({
    required this.animation,
    required this.animationValue,
    required this.child,
  });
  final BouncyButtonAnimation animation;
  final double animationValue;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    switch (animation.type) {
      case BouncyButtonAnimationType.scale:
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

      case BouncyButtonAnimationType.bounce:
        final bounce = animationValue < 0.5
            ? 1.0 - (animationValue * 0.1)
            : 0.95 + ((animationValue - 0.5) * 0.1);
        return Transform.scale(
          scale: bounce,
          child: child,
        );

      case BouncyButtonAnimationType.fade:
        return Opacity(
          opacity: 1.0 - (animationValue * 0.2),
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
