import 'dart:async' show TimeoutException;
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'async_action.dart';
import 'controller.dart';
import 'debug_checks.dart';
import 'enums.dart';
import 'feedback.dart';
import 'styles.dart';
import 'animations.dart';
import 'interactions.dart';
import 'press_core.dart';
import 'press_transform.dart';
import 'theme.dart';
import 'utils.dart';

enum _Variant { standard, primary, secondary, tertiary, icon }

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
    this.onPressed,
    this.onPressedAsync,
    this.onError,
    this.isLoading,
    this.feedback,
    this.cooldown,
    this.controller,
    this.tooltip,
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
    this.leading,
    this.trailing,
    this.gap = 8,
    this.isSelected,
    this.expanded,
    this.disabledReason,
    this.statesController,
    this.timeout,
    this.confirm,
  })  : assert(
          onPressed == null || onPressedAsync == null,
          'Use either onPressed or onPressedAsync, not both.',
        ),
        _variant = _Variant.standard;

  /// Creates a primary style bouncy button.
  ///
  /// Uses [style] if provided, then [BouncyButtonTheme.primaryStyle], then
  /// [BouncyButtonStyle.primary].
  const BouncyButton.primary({
    super.key,
    required this.child,
    this.onPressed,
    this.onPressedAsync,
    this.onError,
    this.isLoading,
    this.feedback,
    this.cooldown,
    this.controller,
    this.tooltip,
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
    this.leading,
    this.trailing,
    this.gap = 8,
    this.isSelected,
    this.expanded,
    this.disabledReason,
    this.statesController,
    this.timeout,
    this.confirm,
  })  : assert(
          onPressed == null || onPressedAsync == null,
          'Use either onPressed or onPressedAsync, not both.',
        ),
        _variant = _Variant.primary;

  /// Creates a secondary style bouncy button.
  ///
  /// Uses [style] if provided, then [BouncyButtonTheme.secondaryStyle], then
  /// [BouncyButtonStyle.secondary].
  ///
  /// That preset is filled, like the primary button, and differs only in size.
  /// To show a less important action, prefer a less prominent fill, such as
  /// [BouncyButtonStyle.tonal].
  const BouncyButton.secondary({
    super.key,
    required this.child,
    this.onPressed,
    this.onPressedAsync,
    this.onError,
    this.isLoading,
    this.feedback,
    this.cooldown,
    this.controller,
    this.tooltip,
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
    this.leading,
    this.trailing,
    this.gap = 8,
    this.isSelected,
    this.expanded,
    this.disabledReason,
    this.statesController,
    this.timeout,
    this.confirm,
  })  : assert(
          onPressed == null || onPressedAsync == null,
          'Use either onPressed or onPressedAsync, not both.',
        ),
        _variant = _Variant.secondary;

  /// Creates a tertiary style bouncy button.
  ///
  /// Uses [style] if provided, then [BouncyButtonTheme.tertiaryStyle], then
  /// [BouncyButtonStyle.flat].
  ///
  /// That preset is filled, like the primary button, and differs only in size.
  /// To show a minor action, prefer [BouncyButtonStyle.outlined] or
  /// [BouncyButtonStyle.ghost].
  const BouncyButton.tertiary({
    super.key,
    required this.child,
    this.onPressed,
    this.onPressedAsync,
    this.onError,
    this.isLoading,
    this.feedback,
    this.cooldown,
    this.controller,
    this.tooltip,
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
    this.leading,
    this.trailing,
    this.gap = 8,
    this.isSelected,
    this.expanded,
    this.disabledReason,
    this.statesController,
    this.timeout,
    this.confirm,
  })  : assert(
          onPressed == null || onPressedAsync == null,
          'Use either onPressed or onPressedAsync, not both.',
        ),
        _variant = _Variant.tertiary;

  /// Creates a button that shows only an icon, such as a close or share
  /// button.
  ///
  /// The [tooltip] is required, because an icon alone gives screen readers
  /// nothing to read. It names the button for them, and shows on hover, long
  /// press, and keyboard focus.
  ///
  /// Uses [style] if provided, then [BouncyButtonTheme.iconStyle], then
  /// [BouncyButtonStyle.icon], which is round with a tap area of at least 48
  /// by 48.
  ///
  /// ```dart
  /// BouncyButton.icon(
  ///   onPressed: share,
  ///   tooltip: 'Share',
  ///   icon: const Icon(Icons.share),
  /// )
  /// ```
  const BouncyButton.icon({
    super.key,
    required Widget icon,
    required String this.tooltip,
    this.onPressed,
    this.onPressedAsync,
    this.onError,
    this.isLoading,
    this.feedback,
    this.cooldown,
    this.controller,
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
    this.isSelected,
    this.expanded,
    this.disabledReason,
    this.statesController,
    this.timeout,
    this.confirm,
  })  : assert(
          onPressed == null || onPressedAsync == null,
          'Use either onPressed or onPressedAsync, not both.',
        ),
        child = icon,
        semanticLabel = null,
        builder = null,
        leading = null,
        trailing = null,
        gap = 8,
        _variant = _Variant.icon;

  final _Variant _variant;

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget or an [Icon] widget.
  final Widget child;

  /// Called when the button is tapped or otherwise activated.
  ///
  /// If this, [onPressedAsync], and [onLongPress] are all null, the button is
  /// disabled.
  final VoidCallback? onPressed;

  /// Called when the button is pressed, showing a loading state until the
  /// returned future completes.
  ///
  /// While it runs, the button ignores further presses, so a payment or form
  /// can't be sent twice. It then shows success or, if the future throws, an
  /// error, as configured by [feedback]. Use either this or [onPressed].
  ///
  /// ```dart
  /// BouncyButton(
  ///   onPressedAsync: () => api.placeOrder(cart),
  ///   onError: (error, stack) => showError(error),
  ///   child: const Text('Pay'),
  /// )
  /// ```
  final Future<void> Function()? onPressedAsync;

  /// Called when [onPressedAsync] throws.
  ///
  /// If null, the error is reported to [FlutterError.reportError], so it is
  /// never silently lost.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Shows the loading state when true, for loading managed outside the
  /// button. While true, the button ignores presses.
  final bool? isLoading;

  /// How the button shows loading, success, and error. If null,
  /// [BouncyButtonTheme.defaultFeedback] is used.
  final BouncyButtonFeedback? feedback;

  /// How long to ignore presses after the button is used, so a quick double
  /// tap doesn't run the action twice.
  ///
  /// For [onPressed], it starts when the button is tapped. For
  /// [onPressedAsync], it starts when the button is ready again, after any
  /// success or error has been shown. Errors count too. During the cooldown
  /// the button looks normal but ignores presses.
  ///
  /// ```dart
  /// BouncyButton(
  ///   onPressed: () => Navigator.of(context).push(route),
  ///   cooldown: const Duration(milliseconds: 600),
  ///   child: const Text('Open'),
  /// )
  /// ```
  final Duration? cooldown;

  /// Controls the button from code: press it, reset it, or follow its status.
  final BouncyButtonController? controller;

  /// A short description shown on hover or long press, and given to screen
  /// readers. Use it for buttons that only have an icon.
  final String? tooltip;

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

  /// A widget before [child], typically an [Icon]. Placed on the right in
  /// right-to-left layouts. Not used with [builder].
  final Widget? leading;

  /// A widget after [child], typically an [Icon]. Placed on the left in
  /// right-to-left layouts. Not used with [builder].
  final Widget? trailing;

  /// The space between [leading], [child], and [trailing].
  final double gap;

  /// Whether a toggle button is on, such as Mute or Bold, or null if this is
  /// not a toggle. Screen readers announce it as checked or not checked.
  ///
  /// The button looks the same either way, so show the state through [style],
  /// for example a filled style when on and a tonal one when off. Keep the
  /// label the same in both states: a label that changes too, such as "Mute"
  /// and "Unmute", would be read alongside a contradicting state.
  ///
  /// ```dart
  /// BouncyButton(
  ///   isSelected: muted,
  ///   onPressed: () => setState(() => muted = !muted),
  ///   style: muted ? BouncyButtonStyle.primary : BouncyButtonStyle.tonal,
  ///   child: const Text('Mute'),
  /// )
  /// ```
  final bool? isSelected;

  /// Whether a menu or section this button opens is showing, or null if it
  /// opens nothing. Screen readers announce it as expanded or collapsed.
  final bool? expanded;

  /// Why the button is disabled, such as "Add a card first".
  ///
  /// While the button is disabled, it is shown as a tooltip and read by
  /// screen readers after the label, so people know what to do. Not used
  /// while the button is enabled.
  final String? disabledReason;

  /// Updated with the pressed, hovered, focused, disabled, and selected
  /// states, for building visuals or testing.
  final WidgetStatesController? statesController;

  /// How long [onPressedAsync] may run before the button gives up and shows
  /// an error, so a request that hangs doesn't leave it loading forever.
  ///
  /// [onError] then receives a [TimeoutException], and the button can be
  /// pressed again. The action itself keeps running, because Dart can't stop
  /// a future, but its result is ignored. An error it throws later is still
  /// reported. If null, there is no limit.
  final Duration? timeout;

  /// Asked before the action runs, such as to show a confirmation dialog.
  /// The action runs only if it returns true.
  ///
  /// While it waits for an answer, the button ignores presses, so a double
  /// tap opens one dialog, and it shows no loading. If it throws, the error
  /// goes to [onError] and the action doesn't run. It applies to [onPressed]
  /// and [onPressedAsync], and to [BouncyButtonController.press].
  ///
  /// ```dart
  /// BouncyButton(
  ///   onPressedAsync: deleteAccount,
  ///   confirm: () async =>
  ///       await showDialog<bool>(
  ///         context: context,
  ///         builder: (context) => const ConfirmDeleteDialog(),
  ///       ) ??
  ///       false,
  ///   style: BouncyButtonStyle.destructive,
  ///   child: const Text('Delete account'),
  /// )
  /// ```
  final Future<bool> Function()? confirm;

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with TickerProviderStateMixin, AsyncActionRunner<BouncyButton> {
  static const Duration _shakeDuration = Duration(milliseconds: 450);

  /// Raises the face while a mouse hovers.
  late final AnimationController _hover = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: _shakeDuration,
  );

  /// Whether another action in a locking scope is running. Set in [build].
  bool _groupLocked = false;

  /// The core's keyboard-style activation, for [press]. Set in [build].
  VoidCallback? _coreActivate;

  /// The run started by the latest activation, for [press].
  Future<void>? _lastRun;

  bool get _isEnabled =>
      widget.enabled &&
      !_groupLocked &&
      (widget.onPressed != null ||
          widget.onPressedAsync != null ||
          widget.onLongPress != null);

  BouncyButtonFeedback get _feedback =>
      widget.feedback ??
      BouncyButtonTheme.of(context)?.defaultFeedback ??
      const BouncyButtonFeedback();

  @override
  Future<void> Function()? get asyncAction => widget.onPressedAsync;

  @override
  void Function(Object error, StackTrace stackTrace)? get asyncOnError =>
      widget.onError;

  @override
  String get asyncErrorContext => 'while running BouncyButton.onPressedAsync';

  @override
  BouncyButtonFeedback get asyncFeedback => _feedback;

  @override
  Duration? get asyncCooldown => widget.cooldown;

  @override
  BouncyButtonController? get asyncController => widget.controller;

  @override
  bool get externalLoading => widget.isLoading ?? false;

  @override
  Duration? get asyncTimeout => widget.timeout;

  @override
  Future<bool> Function()? get asyncConfirm => widget.confirm;

  @override
  void initState() {
    super.initState();
    syncAsyncController();
    assert(() {
      _debugScheduleContentCheck();
      return true;
    }());
  }

  @override
  void didUpdateWidget(BouncyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncAsyncController(oldWidget.controller);
    if (oldWidget.isLoading != widget.isLoading) {
      widget.controller?.notifyStatus();
    }
    assert(() {
      _debugCheckToggleLabel(oldWidget);
      if (oldWidget.style != widget.style) {
        _debugScheduleContentCheck();
      }
      return true;
    }());
  }

  // Debug checks. They only run inside asserts, so release builds leave them
  // out. See debugBouncyChecksEnabled.

  /// The context of the content the app passed in, without this button's own
  /// widgets around it. Only set in debug mode.
  BuildContext? _debugContentContext;

  /// Names this button in debug warnings.
  String get _debugName {
    final context = _debugContentContext;
    final texts = context != null && context.mounted
        ? debugVisibleTexts(context)
        : const <(String, TextStyle?)>[];
    final name = texts.isNotEmpty
        ? texts.map((text) => text.$1).join(' ')
        : widget.tooltip ?? widget.semanticLabel;
    return name == null ? 'A BouncyButton' : 'The BouncyButton "$name"';
  }

  void _debugScheduleContentCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _debugCheckContent());
  }

  /// Warns about an icon with nothing for screen readers to read.
  void _debugCheckIconLabel() {
    final child = widget.child;
    if (widget._variant == _Variant.icon ||
        widget.builder != null ||
        child is! Icon ||
        child.semanticLabel != null ||
        widget.semanticLabel != null ||
        widget.tooltip != null) {
      return;
    }
    debugBouncyWarn(
      'icon-label:${child.icon}',
      'A BouncyButton shows only an icon and has no label, so screen readers '
          'can only call it "button". Use BouncyButton.icon(tooltip: ...), or '
          'set tooltip or semanticLabel.',
    );
  }

  /// Warns when the label changes along with the toggle state.
  void _debugCheckToggleLabel(BouncyButton oldWidget) {
    final before = oldWidget.child;
    final after = widget.child;
    if (oldWidget.isSelected == null ||
        widget.isSelected == null ||
        oldWidget.isSelected == widget.isSelected ||
        before is! Text ||
        after is! Text ||
        before.data == after.data) {
      return;
    }
    debugBouncyWarn(
      'toggle-label:${before.data}:${after.data}',
      'A BouncyButton changed its text from "${before.data}" to '
          '"${after.data}" when isSelected changed. Screen readers already '
          'announce whether it is on, so they would read "${after.data}, '
          'checked". Keep one text, such as "${before.data}", and let '
          'isSelected show the state.',
    );
  }

  /// Checks the label, nested tappables, and text contrast after layout.
  void _debugCheckContent() {
    final context = _debugContentContext;
    if (!mounted || context == null || !context.mounted) {
      return;
    }
    final name = _debugName;
    final texts = debugVisibleTexts(context);
    final visible = texts.map((text) => text.$1).join(' ').trim();

    final label = widget.semanticLabel;
    if (label != null &&
        visible.isNotEmpty &&
        !label.toLowerCase().contains(visible.toLowerCase())) {
      debugBouncyWarn(
        'label-in-name:$label:$visible',
        'The BouncyButton showing "$visible" has the semanticLabel "$label", '
            'which does not contain "$visible". People using voice control '
            'say the text they see, so include it in the label, for example '
            '"$visible ${label.toLowerCase()}".',
      );
    }

    if (debugContainsTappable(context)) {
      debugBouncyWarn(
        'nested:$name',
        '$name contains another widget that handles taps, such as a button, '
            'an InkWell, a GestureDetector, or a text field. Only one of them '
            'gets each tap. Move it out of the button, or use a '
            'BouncyPressable, which supports controls inside it.',
      );
    }

    if (_isEnabled) {
      _debugCheckContrast(name, texts);
    }
  }

  /// Warns when text doesn't stand out enough from the face.
  void _debugCheckContrast(String name, List<(String, TextStyle?)> texts) {
    final style = _style;
    final faces = _debugFaceColors(style);
    if (faces.isEmpty) {
      return;
    }
    for (final (_, textStyle) in texts) {
      final color = textStyle?.color;
      if (color == null) {
        continue;
      }
      final large = debugIsLargeText(textStyle);
      final needed = large ? 3.0 : 4.5;
      for (final face in faces) {
        final ratio = contrastRatio(Color.alphaBlend(color, face), face);
        if (ratio < needed) {
          debugBouncyWarn(
            'contrast:$color:$face',
            '$name has text with a contrast of ${ratio.toStringAsFixed(1)}:1 '
                'against its face, below the ${needed.toStringAsFixed(1)}:1 '
                'needed for ${large ? 'large' : 'normal'} text to be easy to '
                'read. Choose a foregroundColor or backgroundColor further '
                'apart in lightness.',
          );
          return;
        }
      }
    }
  }

  /// The solid colors text is drawn on, or none if they aren't known, such
  /// as for a see-through face or an image.
  List<Color> _debugFaceColors(BouncyButtonStyle style) {
    if (_isGlass(style) || style.fill == BouncyButtonFill.ghost) {
      return const [];
    }
    final decoration = style.decoration;
    final List<Color> colors;
    if (decoration != null) {
      if (decoration.image != null) {
        return const [];
      }
      colors = decoration.gradient?.colors ??
          [if (decoration.color != null) decoration.color!];
    } else {
      final gradient = _usesAccent(style) ? null : _faceGradient(style);
      colors = gradient?.colors ?? [_faceColor(context, style)];
    }
    if (colors.any((color) => color.a < 1)) {
      return const [];
    }
    return colors;
  }

  @override
  void dispose() {
    disposeAsyncAction();
    _shake.dispose();
    _hover.dispose();
    super.dispose();
  }

  void _runFromTap() {
    _lastRun = runAsyncAction();
  }

  /// Runs [BouncyButton.onPressed] once [BouncyButton.confirm] agrees.
  void _confirmThenPress() {
    _lastRun = () async {
      if (await confirmFirst()) {
        widget.onPressed?.call();
      }
    }();
  }

  /// What the core runs on a tap or activation.
  VoidCallback? get _coreTap {
    if (widget.onPressedAsync != null) {
      return _runFromTap;
    }
    if (widget.onPressed == null) {
      return null;
    }
    return widget.confirm == null ? widget.onPressed : _confirmThenPress;
  }

  @override
  Future<void> press() {
    if (widget.onPressedAsync != null && status == BouncyButtonStatus.loading) {
      return runAsyncAction();
    }
    _lastRun = null;
    _coreActivate?.call();
    return _lastRun ?? Future<void>.value();
  }

  @override
  void onAsyncResult(BouncyButtonStatus result) {
    final success = result == BouncyButtonStatus.success;
    if (_interaction.enableHapticFeedback) {
      success ? HapticFeedback.selectionClick() : HapticFeedback.heavyImpact();
    }
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!success && _feedback.shakeOnError && !reduceMotion) {
      _shake.forward(from: 0);
    }
  }

  /// Shows the tooltip while the button has keyboard focus, as a mouse
  /// hover would.
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  /// Keeps the core's state, such as focus and a cooldown, when a tooltip is
  /// added or removed around it.
  final GlobalKey _coreKey = GlobalKey();
  bool _tooltipShownByFocus = false;

  void _handleFocusHighlight(bool focused) {
    if (focused) {
      _tooltipShownByFocus =
          _tooltipKey.currentState?.ensureTooltipVisible() ?? false;
    } else if (_tooltipShownByFocus) {
      _tooltipShownByFocus = false;
      Tooltip.dismissAllToolTips();
    }
  }

  /// Whether the app disabled the button, as opposed to a group lock.
  bool get _disabledByApp =>
      !widget.enabled ||
      (widget.onPressed == null &&
          widget.onPressedAsync == null &&
          widget.onLongPress == null);

  /// The reason to show, while the app keeps the button disabled.
  String? get _activeDisabledReason =>
      _disabledByApp ? widget.disabledReason : null;

  void _handleHover(bool hovered) {
    if (hovered) {
      _hover.forward();
    } else {
      _hover.reverse();
    }
  }

  /// The horizontal shake offset, which dies away over the animation.
  double get _shakeOffset {
    final t = _shake.value;
    if (t == 0 || t == 1) {
      return 0;
    }
    return math.sin(t * math.pi * 6) * 8 * (1 - t);
  }

  BouncyButtonStyle get _style {
    final style = _unresolvedStyle;
    // A glass face would show its depth through it, so neither has depth.
    final flat = style.fill == BouncyButtonFill.ghost ||
        style.fill == BouncyButtonFill.glass;
    return flat && style.elevation != 0 ? style.copyWith(elevation: 0) : style;
  }

  BouncyButtonStyle get _unresolvedStyle {
    final theme = BouncyButtonTheme.of(context);
    return widget.style ??
        switch (widget._variant) {
          _Variant.standard => theme?.primaryStyle ?? const BouncyButtonStyle(),
          _Variant.primary => theme?.primaryStyle ?? BouncyButtonStyle.primary,
          _Variant.secondary =>
            theme?.secondaryStyle ?? BouncyButtonStyle.secondary,
          _Variant.tertiary => theme?.tertiaryStyle ?? BouncyButtonStyle.flat,
          _Variant.icon => theme?.iconStyle ?? BouncyButtonStyle.icon,
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

  bool _destructive(BouncyButtonStyle style) =>
      style.tone == BouncyButtonTone.destructive;

  /// The main color: primary, or error for a destructive button.
  Color _mainColor(ColorScheme scheme, BouncyButtonStyle style) =>
      _destructive(style) ? scheme.error : scheme.primary;

  /// The softer container color used by tonal buttons.
  Color _containerColor(ColorScheme scheme, BouncyButtonStyle style) =>
      _destructive(style) ? scheme.errorContainer : scheme.secondaryContainer;

  Color _faceColor(BuildContext context, BouncyButtonStyle style) {
    final scheme = Theme.of(context).colorScheme;
    switch (style.fill) {
      case BouncyButtonFill.filled:
        if (!_isEnabled) {
          return style.disabledColor ?? Colors.grey;
        }
        return style.backgroundColor ??
            style.hslColor?.toColor() ??
            _mainColor(scheme, style);
      case BouncyButtonFill.tonal:
        if (!_isEnabled) {
          // Opaque, so the depth behind it doesn't show through.
          return style.disabledColor ??
              Color.alphaBlend(scheme.onSurface.withAlpha(31), scheme.surface);
        }
        return style.backgroundColor ??
            style.hslColor?.toColor() ??
            _containerColor(scheme, style);
      case BouncyButtonFill.outlined:
        return scheme.surface;
      case BouncyButtonFill.ghost:
        return Colors.transparent;
      case BouncyButtonFill.glass:
        final tint = style.backgroundColor ?? scheme.surface;
        if (_highContrast(context)) {
          return tint.withAlpha(255);
        }
        return tint.withAlpha(_isEnabled ? 110 : 60);
    }
  }

  bool _highContrast(BuildContext context) =>
      MediaQuery.maybeHighContrastOf(context) ?? false;

  bool _isGlass(BouncyButtonStyle style) =>
      style.fill == BouncyButtonFill.glass && style.decoration == null;

  /// The text and border color of outlined and ghost buttons.
  Color _accentColor(BuildContext context, BouncyButtonStyle style) {
    final scheme = Theme.of(context).colorScheme;
    if (!_isEnabled) {
      return style.disabledColor ?? scheme.onSurface.withAlpha(97);
    }
    return style.backgroundColor ??
        style.hslColor?.toColor() ??
        _mainColor(scheme, style);
  }

  bool _usesAccent(BouncyButtonStyle style) =>
      style.fill == BouncyButtonFill.outlined ||
      style.fill == BouncyButtonFill.ghost;

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
    if (_usesAccent(style) && style.decoration == null) {
      return _accentColor(context, style);
    }
    final base = _faceBaseColor(context, style);
    if (base == null) {
      return null;
    }
    final scheme = Theme.of(context).colorScheme;
    if (base == scheme.primary) {
      return scheme.onPrimary;
    }
    if (base == scheme.error) {
      return scheme.onError;
    }
    if (base == scheme.secondaryContainer) {
      return scheme.onSecondaryContainer;
    }
    if (base == scheme.errorContainer) {
      return scheme.onErrorContainer;
    }
    if (_isGlass(style)) {
      if (!_isEnabled) {
        return scheme.onSurface.withAlpha(97);
      }
      // Judged against the opaque tint, as the backdrop is unknown.
      return style.backgroundColor == null
          ? (_destructive(style) ? scheme.error : scheme.onSurface)
          : ThemeData.estimateBrightnessForColor(style.backgroundColor!) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87;
    }
    return ThemeData.estimateBrightnessForColor(base) == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Color _depthColor(BuildContext context, BouncyButtonStyle style) {
    if (style.shadowColor != null) {
      return style.shadowColor!;
    }
    // These have no depth, and their face is clear or see-through, so a depth
    // layer would show through it.
    if (style.fill == BouncyButtonFill.ghost ||
        style.fill == BouncyButtonFill.glass) {
      return Colors.transparent;
    }
    if (_usesAccent(style) && style.decoration == null) {
      return _outlineColor(context, style);
    }
    final base = _faceBaseColor(context, style) ?? _faceColor(context, style);
    final scheme = Theme.of(context).colorScheme;
    // Dark themes use a pastel primary color, which turns neon when only its
    // HSL lightness is lowered. Tonal container colors do the same.
    if (base == scheme.primary ||
        base == scheme.error ||
        style.fill == BouncyButtonFill.tonal) {
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

  /// The border and depth color of an outlined button.
  Color _outlineColor(BuildContext context, BouncyButtonStyle style) {
    final scheme = Theme.of(context).colorScheme;
    if (!_isEnabled) {
      return scheme.onSurface.withAlpha(31);
    }
    return style.backgroundColor ??
        style.hslColor?.toColor() ??
        (_destructive(style) ? scheme.error : scheme.outline);
  }

  BoxDecoration _faceDecoration(
    BuildContext context,
    BouncyButtonStyle style, {
    BorderRadiusGeometry? morphRadius,
  }) {
    if (style.decoration != null) {
      return style.decoration!;
    }
    final gradient = _usesAccent(style) ? null : _faceGradient(style);
    final outlined = style.fill == BouncyButtonFill.outlined;
    return BoxDecoration(
      gradient: gradient,
      color: gradient == null ? _faceColor(context, style) : null,
      borderRadius: morphRadius ?? _borderRadius(style),
      shape: morphRadius != null ? BoxShape.rectangle : style.shape,
      border: style.border ??
          (outlined
              ? Border.all(color: _outlineColor(context, style), width: 2)
              : _isGlass(style)
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(
                            _highContrast(context) ? 160 : 40,
                          ),
                    )
                  : null),
      boxShadow:
          style.shadows ?? (style.shadow != null ? [style.shadow!] : null),
    );
  }

  BoxDecoration _shadowDecoration(
    BuildContext context,
    BouncyButtonStyle style, {
    BorderRadiusGeometry? morphRadius,
  }) {
    return style.shadowDecoration ??
        BoxDecoration(
          color: _depthColor(context, style),
          borderRadius: morphRadius ?? _borderRadius(style),
          shape: morphRadius != null ? BoxShape.rectangle : style.shape,
        );
  }

  bool _morphs(BouncyButtonStyle style) =>
      style.pressedBorderRadius != null &&
      style.decoration == null &&
      style.shadowDecoration == null;

  /// The corners at press progress [t], for a style that [_morphs].
  BorderRadiusGeometry _morphRadius(BouncyButtonStyle style, double t) {
    final rest = style.shape == BoxShape.circle
        ? BorderRadius.circular(style.height / 2)
        : _borderRadius(style)!;
    return BorderRadiusGeometry.lerp(
      rest,
      style.pressedBorderRadius,
      t.clamp(0.0, 1.0),
    )!;
  }

  /// The hover tint and keyboard focus ring, painted over the face.
  BoxDecoration _highlightDecoration(
    BouncyButtonStyle style,
    BouncyButtonInteraction interaction,
    Color? foreground,
    PressCoreData press, {
    BorderRadiusGeometry? morphRadius,
  }) {
    final fallback = foreground ?? Colors.black;
    final shape = morphRadius != null
        ? BoxShape.rectangle
        : style.decoration?.shape ?? style.shape;
    // A ghost button has no depth to push in, so a tint shows the press.
    final ghostPressed = (style.fill == BouncyButtonFill.ghost ||
            style.fill == BouncyButtonFill.glass) &&
        press.isPressed;
    return BoxDecoration(
      color: ghostPressed
          ? interaction.highlightColor ?? fallback.withAlpha(36)
          : press.isHovered
              ? interaction.hoverColor ?? fallback.withAlpha(20)
              : null,
      border: press.isFocused
          ? Border.all(
              color: interaction.focusColor ?? fallback,
              // Thicker when the system asks for more contrast.
              width: _highContrast(context) ? 3 : 2,
            )
          : null,
      borderRadius: shape == BoxShape.circle
          ? null
          : morphRadius ??
              style.decoration?.borderRadius ??
              _borderRadius(style),
      shape: shape,
    );
  }

  Widget _buildContent(
    BuildContext context,
    BouncyButtonStyle style,
    PressCoreData press,
  ) {
    final builder = widget.builder;
    Widget content = builder != null
        ? builder(context, press.isPressed)
        : Padding(
            padding: style.padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Align(
              alignment: style.alignment ?? Alignment.center,
              widthFactor: 1,
              heightFactor: 1,
              child: _withIcons(),
            ),
          );
    assert(() {
      // Marks where the app's content starts, for the debug checks.
      final appContent = content;
      content = Builder(
        builder: (context) {
          _debugContentContext = context;
          return appContent;
        },
      );
      return true;
    }());
    final status = this.status;
    final showContent = status == BouncyButtonStatus.idle;
    // The content stays laid out while hidden, so the button keeps its size.
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: showContent,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          maintainSemantics: true,
          child: content,
        ),
        if (!showContent)
          Positioned.fill(
            child: ExcludeSemantics(
              child: Center(child: _buildStatus(context, status)),
            ),
          ),
      ],
    );
  }

  /// Places [BouncyButton.leading] and [BouncyButton.trailing] around the
  /// child.
  Widget _withIcons() {
    final leading = widget.leading;
    final trailing = widget.trailing;
    if (leading == null && trailing == null) {
      return widget.child;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // A long label wraps when there is a width limit. Without one, as in
        // a Row, a Flexible child would throw.
        final child = constraints.hasBoundedWidth
            ? Flexible(child: widget.child)
            : widget.child;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, SizedBox(width: widget.gap)],
            child,
            if (trailing != null) ...[SizedBox(width: widget.gap), trailing],
          ],
        );
      },
    );
  }

  Widget _buildStatus(BuildContext context, BouncyButtonStatus status) {
    final feedback = _feedback;
    switch (status) {
      case BouncyButtonStatus.loading:
        final builder = feedback.loadingBuilder;
        if (builder != null) {
          return builder(context);
        }
        final spinner = SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: IconTheme.of(context).color,
          ),
        );
        final text = feedback.loadingText;
        if (text == null) {
          return spinner;
        }
        // The button keeps its size, so longer text is cut off.
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              spinner,
              SizedBox(width: widget.gap),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
        );
      case BouncyButtonStatus.success:
        return feedback.successBuilder?.call(context) ??
            const Icon(Icons.check_rounded);
      case BouncyButtonStatus.error:
        return feedback.errorBuilder?.call(context) ??
            const Icon(Icons.error_outline_rounded);
      case BouncyButtonStatus.idle:
        return const SizedBox.shrink();
    }
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
    if (foreground != null ||
        style.textStyle != null ||
        style.iconSize != null) {
      content = IconTheme.merge(
        data: IconThemeData(color: foreground, size: style.iconSize),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground).merge(style.textStyle),
          child: content,
        ),
      );
    }
    final isCircle = style.shape == BoxShape.circle;
    final Widget face = ConstrainedBox(
      constraints: isCircle
          ? BoxConstraints.tightFor(height: style.height)
          : BoxConstraints(minHeight: style.height),
      child: _morphs(style)
          ? AnimatedBuilder(
              animation: press.animation,
              // Only the decoration changes per frame, not the content.
              child: _buildInk(style, interaction, press, content),
              builder: (context, child) {
                final radius = _morphRadius(style, press.animation.value);
                return DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: _highlightDecoration(
                    style,
                    interaction,
                    foreground,
                    press,
                    morphRadius: radius,
                  ),
                  child: Container(
                    decoration: _faceDecoration(
                      context,
                      style,
                      morphRadius: radius,
                    ),
                    clipBehavior: style.clipBehavior,
                    child: child,
                  ),
                );
              },
            )
          : DecoratedBox(
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
    if (!_isGlass(style) || _highContrast(context)) {
      return face;
    }
    // Blurs what is behind the face, clipped to its shape.
    final blurred = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: face,
    );
    if (isCircle) {
      return ClipOval(child: blurred);
    }
    return ClipRRect(
      borderRadius: _borderRadius(style)!.resolve(Directionality.of(context)),
      child: blurred,
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
    final morphs = _morphs(style);
    Widget shadowFor(double t) => Positioned(
          top: style.elevation,
          bottom: 0,
          left: 0,
          right: 0,
          child: DecoratedBox(
            decoration: _shadowDecoration(
              context,
              style,
              morphRadius: morphs ? _morphRadius(style, t) : null,
            ),
          ),
        );
    final staticShadow = morphs ? null : shadowFor(0);
    final face = _buildFace(context, style, interaction, press);
    final lift = reduceMotion ? 0.0 : interaction.hoverLift;

    Widget content = AnimatedBuilder(
      animation: Listenable.merge([press.animation, _shake, _hover]),
      builder: (context, _) {
        final value = press.animation.value;
        // A spring can overshoot past fully pressed, but the face can't go
        // through its depth.
        final depth = value > 1 ? 1.0 : value;
        final hoverRise = lift * _hover.value * (1 - depth.clamp(0.0, 1.0));
        return PressTransform(
          animation: animationConfig,
          animationValue: press.animation.value,
          reduceMotion: reduceMotion,
          child: Transform.translate(
            offset: Offset(_shakeOffset, 0),
            child: Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.none,
              children: [
                staticShadow ?? shadowFor(value),
                Padding(
                  padding: EdgeInsets.only(bottom: style.elevation),
                  child: Transform.translate(
                    offset: Offset(0, style.elevation * depth - hoverRise),
                    child: face,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    final width =
        style.width ?? (style.shape == BoxShape.circle ? style.height : null);
    if (width != null) {
      content = SizedBox(width: width, child: content);
    } else if (style.minWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(minWidth: style.minWidth!),
        child: content,
      );
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

    final minTapTarget = style.minTapTarget;
    if (minTapTarget != null) {
      // Inside the gesture detector, so the extra space also takes taps.
      content = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minTapTarget,
          minHeight: minTapTarget,
        ),
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final interaction = _interaction;
    final animation = _animationConfig;

    final isAsync = widget.onPressedAsync != null;
    assert(() {
      _debugCheckIconLabel();
      if (isAsync || widget.isLoading != null) {
        debugCheckFeedbackLabels(context, 'BouncyButton');
      }
      return true;
    }());
    _groupLocked = isAsync && watchGroupLock(context);
    Widget button = PressCore(
      key: _coreKey,
      onTap: _coreTap,
      busy: asyncBusy,
      semanticValue: _feedback.labelFor(status),
      // Async buttons cool down once they are ready again, through the runner.
      cooldown: isAsync ? null : widget.cooldown,
      tooltip: widget.tooltip,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTapDown,
      onTapUp: widget.onTapUp,
      onTapCancel: widget.onTapCancel,
      enabled: widget.enabled && !_groupLocked,
      duration: animation.duration,
      reverseDuration: animation.reverseDuration,
      curve: animation.curve,
      reverseCurve: animation.reverseCurve,
      spring: animation.spring,
      onHoverChange: _handleHover,
      enableSound: interaction.enableSound,
      onPressSound: interaction.onPressSound,
      haptic: interaction.enableHapticFeedback
          ? interaction.hapticFeedbackType
          : null,
      cursor: _cursor(interaction),
      hitTestBehavior: widget.hitTestBehavior,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      semanticHint: _activeDisabledReason,
      isSelected: widget.isSelected,
      expanded: widget.expanded,
      statesController: widget.statesController,
      onFocusHighlightChange: _handleFocusHighlight,
      debugName: widget.tooltip != null
          ? 'The BouncyButton "${widget.tooltip}"'
          : widget.semanticLabel != null
              ? 'The BouncyButton "${widget.semanticLabel}"'
              : widget.child is Text
                  ? 'The BouncyButton "${(widget.child as Text).data}"'
                  : 'A BouncyButton',
      debugTapTargetFix: style.minTapTarget == null
          ? 'Set minTapTarget: 48 on its style to enlarge the tap area '
              'without changing how it looks.'
          : null,
      labelReplacesChildSemantics: true,
      builder: (context, press) {
        _coreActivate = press.handleActivate;
        return _buildBody(context, style, interaction, animation, press);
      },
    );

    final tooltip = _activeDisabledReason ?? widget.tooltip;
    if (tooltip != null) {
      // The core gives screen readers the tooltip and reason, so this doesn't.
      button = Tooltip(
        key: _tooltipKey,
        message: tooltip,
        excludeFromSemantics: true,
        child: button,
      );
    }

    if (style.margin != null) {
      button = Padding(padding: style.margin!, child: button);
    }
    return button;
  }
}
