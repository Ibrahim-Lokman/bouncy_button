import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';
import 'exclusive_scope.dart';

/// What [PressCore] passes to its builder.
///
/// [animation] runs from 0 at rest to 1 when fully pressed. It is passed as an
/// [Animation], not a value, so that animation frames only rebuild the parts
/// that listen to it.
@immutable
class PressCoreData {
  /// Creates the data for a [PressCore] builder.
  const PressCoreData({
    required this.animation,
    required this.isEnabled,
    required this.isPressed,
    required this.isHovered,
    required this.isFocused,
    required this.reduceMotion,
    required this.handleTap,
    required this.handleTapDown,
    required this.handleTapUp,
    required this.handleTapCancel,
  });

  /// The press animation.
  final Animation<double> animation;

  /// Whether the control responds to input.
  final bool isEnabled;

  /// Whether the control is being held down.
  final bool isPressed;

  /// Whether to show a hover highlight.
  final bool isHovered;

  /// Whether to show a keyboard focus highlight.
  final bool isFocused;

  /// Whether the system asks for reduced motion.
  final bool reduceMotion;

  /// Handlers for a recognizer inside the builder, such as an InkWell, which
  /// wins the gesture over the core's own detector.
  final VoidCallback handleTap;

  /// See [handleTap].
  final GestureTapDownCallback handleTapDown;

  /// See [handleTap].
  final GestureTapUpCallback handleTapUp;

  /// See [handleTap].
  final VoidCallback handleTapCancel;
}

/// The press behavior shared by every widget in this package: gestures, press
/// animation, focus, hover, semantics, and haptics.
///
/// It takes plain values and imports no Material code, so it works in any app.
class PressCore extends StatefulWidget {
  /// Creates a press core.
  const PressCore({
    super.key,
    required this.builder,
    required this.duration,
    required this.curve,
    this.reverseDuration,
    this.reverseCurve,
    this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.enabled = true,
    this.haptic,
    this.cursor,
    this.hitTestBehavior,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.semanticsButton = true,
    this.labelReplacesChildSemantics = false,
  });

  /// Builds the control. Called when state changes, not on animation frames.
  final Widget Function(BuildContext context, PressCoreData data) builder;

  /// Duration of the press.
  final Duration duration;

  /// Duration of the release. Defaults to [duration].
  final Duration? reverseDuration;

  /// Curve of the press.
  final Curve curve;

  /// Curve of the release. Defaults to [curve].
  final Curve? reverseCurve;

  /// Called when the control is tapped or activated.
  final VoidCallback? onTap;

  /// Called when the control is long-pressed.
  final VoidCallback? onLongPress;

  /// Called when a press starts.
  final GestureTapDownCallback? onTapDown;

  /// Called when a press ends with a tap.
  final GestureTapUpCallback? onTapUp;

  /// Called when a press ends without a tap, such as when the finger moves
  /// away, or a long press takes over.
  final VoidCallback? onTapCancel;

  /// Whether the control responds to input. A control also needs [onTap] or
  /// [onLongPress] to be enabled.
  final bool enabled;

  /// The haptic feedback for a press, or null for none.
  final HapticFeedbackType? haptic;

  /// The mouse cursor. Defaults to a click cursor when enabled.
  final MouseCursor? cursor;

  /// How the gesture detector behaves during hit testing. Defaults to
  /// [HitTestBehavior.opaque].
  final HitTestBehavior? hitTestBehavior;

  /// An optional focus node.
  final FocusNode? focusNode;

  /// Whether to request focus initially.
  final bool autofocus;

  /// The screen reader label.
  final String? semanticLabel;

  /// Whether screen readers announce this as a button.
  ///
  /// Set this to false for a control containing other controls, so those stay
  /// separately reachable.
  final bool semanticsButton;

  /// Whether [semanticLabel] hides the child's own semantics.
  ///
  /// This suits a button with simple content. It would hide the controls
  /// inside a wrapper.
  final bool labelReplacesChildSemantics;

  @override
  State<PressCore> createState() => _PressCoreState();
}

class _PressCoreState extends State<PressCore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  FocusNode? _internalFocusNode;

  bool _isPressed = false;
  bool _isLongPressing = false;
  bool _showHover = false;
  bool _showFocus = false;
  bool _reduceMotion = false;

  /// Controls below this one that are being pressed. While there are any, this
  /// one stays still, as the touch belongs to them.
  final Set<_PressCoreState> _activeChildren = {};

  /// The enclosing control that was told about this one's press.
  _PressCoreState? _notifiedParent;

  /// The scope holding this control's press, if any.
  ExclusivePressOwner? _exclusiveOwner;

  /// Set when another control held the press as this gesture began, so the
  /// whole gesture is ignored. Cleared by the next pointer down.
  bool _ignoringGesture = false;

  /// Set when a press was released before it finished going down. The release
  /// then waits, so a quick tap still shows the whole press.
  bool _releasePending = false;

  bool get _isEnabled =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_handleAnimationStatus);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(PressCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
    // The gesture callbacks are about to be removed, so nothing else will
    // release a press that is in progress.
    if (!_isEnabled && _isPressed) {
      _isPressed = false;
      _isLongPressing = false;
      _releasePending = false;
      _endOwnership();
      _controller.reverse();
      // User code could call setState from this callback, which isn't allowed
      // during a build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onTapCancel?.call();
        }
      });
    }
  }

  @override
  void deactivate() {
    _endOwnership();
    _activeChildren.clear();
    super.deactivate();
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _controller
      ..duration = _reduceMotion ? Duration.zero : widget.duration
      ..reverseDuration =
          _reduceMotion ? Duration.zero : widget.reverseDuration;
    _animation
      ..curve = widget.curve
      ..reverseCurve = widget.reverseCurve;
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _releasePending) {
      _releasePending = false;
      _controller.reverse();
    }
  }

  /// Tells the parent and the exclusive scope that this press is over.
  void _endOwnership() {
    _notifiedParent?._markChild(this, active: false);
    _notifiedParent = null;
    _exclusiveOwner?.release(this);
    _exclusiveOwner = null;
  }

  /// Records that a control below this one started or ended a press.
  void _markChild(_PressCoreState child, {required bool active}) {
    final wasActive = _activeChildren.isNotEmpty;
    if (active) {
      _activeChildren.add(child);
    } else {
      _activeChildren.remove(child);
    }
    final isActive = _activeChildren.isNotEmpty;
    if (wasActive == isActive) {
      return;
    }
    // The press can also start here first, depending on arena order.
    if (isActive) {
      _handleTapCancel();
    }
    // Ancestors further up must stay still too.
    if (isActive) {
      _notifiedParent ??=
          context.getInheritedWidgetOfExactType<_PressCoreScope>()?.state;
      _notifiedParent?._markChild(this, active: true);
    } else if (!_isPressed) {
      _notifiedParent?._markChild(this, active: false);
      _notifiedParent = null;
    }
  }

  /// Starts a press. Returns false if none started: one was already in
  /// progress, it belongs to a control below this one, or the exclusive scope
  /// gave it to another control.
  bool _press({bool withHaptics = true}) {
    _releasePending = false;
    if (_isPressed || _ignoringGesture || _activeChildren.isNotEmpty) {
      return false;
    }
    // In this order, so that a parent gives up any claim before this takes it.
    final parent =
        context.getInheritedWidgetOfExactType<_PressCoreScope>()?.state;
    parent?._markChild(this, active: true);
    final owner = ExclusivePressOwner.maybeOf(context);
    if (owner != null && !owner.claim(this)) {
      parent?._markChild(this, active: false);
      _ignoringGesture = true;
      return false;
    }
    _notifiedParent = parent;
    _exclusiveOwner = owner;
    setState(() => _isPressed = true);
    _controller.forward();
    if (withHaptics) {
      _provideHapticFeedback();
    }
    return true;
  }

  /// Ends a press. Returns false if none was in progress.
  bool _release({required bool completed}) {
    if (!_isPressed) {
      return false;
    }
    _endOwnership();
    setState(() => _isPressed = false);
    // A quick tap can end before the first animation frame. Letting the press
    // run to the end keeps it visible.
    if (completed && _controller.status == AnimationStatus.forward) {
      _releasePending = true;
    } else {
      _controller.reverse();
    }
    return true;
  }

  /// Handles activation that has no pointer: the keyboard and screen readers.
  void _activate() {
    final onTap = widget.onTap;
    if (!_isEnabled || onTap == null) {
      return;
    }
    if (!_isPressed) {
      _releasePending = true;
      _controller.forward();
    }
    onTap();
  }

  void _provideHapticFeedback() {
    switch (widget.haptic) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
      case null:
        break;
    }
  }

  // An inner InkWell and the outer detector can both report one press, so user
  // callbacks only fire when the state actually changes.

  void _handleTapDown(TapDownDetails details) {
    if (_press()) {
      widget.onTapDown?.call(details);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_release(completed: true)) {
      widget.onTapUp?.call(details);
    }
  }

  void _handleTapCancel() {
    if (_release(completed: false)) {
      widget.onTapCancel?.call();
    }
  }

  void _handleTap() {
    if (_isEnabled && !_ignoringGesture) {
      widget.onTap?.call();
    }
  }

  void _handleLongPress() {
    if (!_ignoringGesture) {
      widget.onLongPress?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _isEnabled;
    final hasTap = enabled && widget.onTap != null;
    final hasLongPress = enabled && widget.onLongPress != null;
    final labelReplacesChild =
        widget.labelReplacesChildSemantics && widget.semanticLabel != null;

    return Semantics(
      container: true,
      button: widget.semanticsButton,
      explicitChildNodes: !widget.semanticsButton,
      enabled: widget.semanticsButton ? enabled : null,
      label: widget.semanticLabel,
      onTap: hasTap ? _activate : null,
      onLongPress: hasLongPress ? widget.onLongPress : null,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        mouseCursor: widget.cursor ??
            (enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
        actions: <Type, Action<Intent>>{
          if (hasTap) ...{
            ActivateIntent: _FocusedAction<ActivateIntent>(
              _focusNode,
              _activate,
            ),
            ButtonActivateIntent: _FocusedAction<ButtonActivateIntent>(
              _focusNode,
              _activate,
            ),
          },
        },
        onShowHoverHighlight: (value) => setState(() => _showHover = value),
        onShowFocusHighlight: (value) => setState(() => _showFocus = value),
        child: ExcludeSemantics(
          excluding: labelReplacesChild,
          child: Listener(
            onPointerDown: (_) => _ignoringGesture = false,
            child: GestureDetector(
              behavior: widget.hitTestBehavior ?? HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTapDown: enabled ? _handleTapDown : null,
              onTapUp: enabled ? _handleTapUp : null,
              onTap: enabled ? _handleTap : null,
              onTapCancel: enabled ? _handleTapCancel : null,
              onLongPressStart: hasLongPress
                  ? (_) {
                      _isLongPressing = true;
                      _press(withHaptics: false);
                    }
                  : null,
              onLongPress: hasLongPress ? _handleLongPress : null,
              onLongPressEnd: hasLongPress
                  ? (_) {
                      _isLongPressing = false;
                      _release(completed: true);
                    }
                  : null,
              onLongPressCancel: hasLongPress
                  ? () {
                      // Also fires for ordinary taps, which release themselves.
                      if (_isLongPressing) {
                        _isLongPressing = false;
                        _release(completed: false);
                      }
                    }
                  : null,
              child: _PressCoreScope(
                state: this,
                child: widget.builder(
                  context,
                  PressCoreData(
                    animation: _animation,
                    isEnabled: enabled,
                    isPressed: _isPressed,
                    isHovered: _showHover,
                    isFocused: _showFocus,
                    reduceMotion: _reduceMotion,
                    handleTap: _handleTap,
                    handleTapDown: _handleTapDown,
                    handleTapUp: _handleTapUp,
                    handleTapCancel: _handleTapCancel,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets a [PressCore] find the one enclosing it.
class _PressCoreScope extends InheritedWidget {
  const _PressCoreScope({required this.state, required super.child});

  final _PressCoreState state;

  @override
  bool updateShouldNotify(_PressCoreScope oldWidget) => false;
}

/// Activates only when [node] itself has focus.
///
/// Action lookup walks up the tree, so without this, pressing Enter in a
/// focused child with no action of its own would activate this control.
class _FocusedAction<T extends Intent> extends Action<T> {
  _FocusedAction(this.node, this.onInvoke);

  final FocusNode node;
  final VoidCallback onInvoke;

  @override
  bool isEnabled(T intent) => node.hasPrimaryFocus;

  @override
  void invoke(T intent) => onInvoke();
}
