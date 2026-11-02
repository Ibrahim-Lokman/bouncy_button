import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';
import 'exclusive_scope.dart';
import 'spring.dart';

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
    required this.handleActivate,
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

  /// Activates the control as the keyboard does: runs the tap callback with
  /// the press animation. Ignored while disabled, busy, or cooling down.
  final VoidCallback handleActivate;
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
    this.busy = false,
    this.semanticValue,
    this.spring,
    this.onHoverChange,
    this.enableSound = false,
    this.onPressSound,
    this.cooldown,
    this.tooltip,
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

  /// Whether the control is working, such as waiting for a request. It keeps
  /// focus and looks enabled, but ignores presses.
  final bool busy;

  /// A screen reader value, such as "Loading". Changes are announced.
  final String? semanticValue;

  /// Spring physics for the press. When set, [duration] and the curves are
  /// not used.
  final BouncyPressSpring? spring;

  /// Called when the hover highlight starts or stops: only for a mouse, and
  /// only while enabled.
  final ValueChanged<bool>? onHoverChange;

  /// Whether to play the system click sound on a press.
  final bool enableSound;

  /// Called on a press to play a sound of your own.
  final VoidCallback? onPressSound;

  /// How long to ignore presses after [onTap] or [onLongPress] runs.
  final Duration? cooldown;

  /// A short description, given to screen readers as the tooltip.
  final String? tooltip;

  @override
  State<PressCore> createState() => _PressCoreState();
}

class _PressCoreState extends State<PressCore> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  /// Drives the press when [PressCore.spring] is set. Unbounded, because a
  /// spring overshoots.
  AnimationController? _springController;
  double _springTarget = 0;

  /// How far a spring press must get before a quick tap's release begins, so
  /// the press stays visible.
  static const double _quickTapDepth = 0.9;
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

  /// Runs while presses are ignored after an action. An animation rather than
  /// a timer, so that tests can wait for it with pumpAndSettle.
  AnimationController? _cooldown;

  bool get _coolingDown => _cooldown?.isAnimating ?? false;

  /// Whether presses are being ignored for now.
  bool get _ignoringPresses => widget.busy || _coolingDown;

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
    if ((oldWidget.spring == null) != (widget.spring == null)) {
      _switchDriver();
    }
    // The gesture callbacks are about to be removed, so nothing else will
    // release a press that is in progress.
    if (!_isEnabled && _isPressed) {
      _isPressed = false;
      _isLongPressing = false;
      _releasePending = false;
      _endOwnership();
      _driveUp();
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
    _springController?.dispose();
    _cooldown?.dispose();
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
      _driveUp();
    }
  }

  bool get _usesSpring => widget.spring != null;

  Animation<double> get _pressAnimation =>
      _usesSpring ? _ensureSpringController() : _animation;

  AnimationController _ensureSpringController() {
    return _springController ??= AnimationController.unbounded(vsync: this)
      ..addListener(_handleSpringTick);
  }

  /// Keeps the button where it is when switching between curve and spring.
  void _switchDriver() {
    if (_usesSpring) {
      final value = _animation.value;
      _controller.stop();
      _ensureSpringController().value = value;
      _springTarget = _isPressed ? 1 : 0;
      _springTo(_springTarget);
    } else {
      final value = _springController?.value ?? 0;
      _springController?.stop();
      _controller.value = value.clamp(0.0, 1.0);
      _isPressed ? _controller.forward() : _controller.reverse();
    }
  }

  void _driveDown() {
    if (_usesSpring) {
      _springTo(1);
    } else {
      _controller.forward();
    }
  }

  void _driveUp() {
    if (_usesSpring) {
      _springTo(0);
    } else {
      _controller.reverse();
    }
  }

  /// Whether the press is still on its way down.
  bool get _stillGoingDown => _usesSpring
      ? _springTarget == 1 && _springController!.value < _quickTapDepth
      : _controller.status == AnimationStatus.forward;

  /// Animates toward [target], starting from the current position and speed.
  void _springTo(double target) {
    final controller = _ensureSpringController();
    _springTarget = target;
    if (_reduceMotion) {
      controller.value = target;
      return;
    }
    final spring = widget.spring!;
    controller.animateWith(
      SpringSimulation(
        SpringDescription.withDampingRatio(
          mass: spring.mass,
          stiffness: spring.stiffness,
          ratio: spring.dampingRatio,
        ),
        controller.value,
        target,
        controller.velocity,
      ),
    );
  }

  void _handleSpringTick() {
    if (_releasePending &&
        _springTarget == 1 &&
        _springController!.value >= _quickTapDepth) {
      _releasePending = false;
      _driveUp();
    }
  }

  void _startCooldown() {
    final cooldown = widget.cooldown;
    if (cooldown == null || cooldown <= Duration.zero) {
      return;
    }
    (_cooldown ??= AnimationController(vsync: this))
      ..duration = cooldown
      ..forward(from: 0);
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
    if (_isPressed ||
        _ignoringPresses ||
        _ignoringGesture ||
        _activeChildren.isNotEmpty) {
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
    // A new press takes over from a quick tap that is still finishing.
    _releasePending = false;
    setState(() => _isPressed = true);
    _driveDown();
    if (withHaptics) {
      _provideHapticFeedback();
      _playSound();
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
    if (completed && _stillGoingDown) {
      _releasePending = true;
    } else {
      _driveUp();
    }
    return true;
  }

  /// Handles activation that has no pointer: the keyboard and screen readers.
  void _activate() {
    final onTap = widget.onTap;
    if (!_isEnabled || _ignoringPresses || onTap == null) {
      return;
    }
    if (!_isPressed) {
      _releasePending = true;
      _driveDown();
      // A spring under reduced motion arrives at once, so release now.
      if (!_stillGoingDown && _usesSpring) {
        _handleSpringTick();
      }
    }
    onTap();
    _startCooldown();
  }

  void _playSound() {
    if (widget.enableSound) {
      SystemSound.play(SystemSoundType.click);
    }
    widget.onPressSound?.call();
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
    final onTap = widget.onTap;
    if (_isEnabled && !_ignoringPresses && !_ignoringGesture && onTap != null) {
      onTap();
      _startCooldown();
    }
  }

  void _handleLongPress() {
    final onLongPress = widget.onLongPress;
    if (!_ignoringPresses && !_ignoringGesture && onLongPress != null) {
      onLongPress();
      _startCooldown();
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
      tooltip: widget.tooltip,
      value: widget.semanticValue,
      liveRegion: widget.semanticValue != null,
      onTap: hasTap ? _activate : null,
      onLongPress: hasLongPress ? _handleLongPress : null,
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
        onShowHoverHighlight: (value) {
          setState(() => _showHover = value);
          widget.onHoverChange?.call(value);
        },
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
                    animation: _pressAnimation,
                    isEnabled: enabled,
                    isPressed: _isPressed,
                    isHovered: _showHover,
                    isFocused: _showFocus,
                    reduceMotion: _reduceMotion,
                    handleTap: _handleTap,
                    handleTapDown: _handleTapDown,
                    handleTapUp: _handleTapUp,
                    handleTapCancel: _handleTapCancel,
                    handleActivate: _activate,
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
