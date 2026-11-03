import 'dart:async';

import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'enums.dart';
import 'exclusive_scope.dart';
import 'feedback.dart';

/// Runs an async action for a widget: loading, then success or error, then
/// an optional cooldown, with the group lock and controller.
///
/// Waits use animation controllers rather than timers, so that widget tests
/// can wait for them with `pumpAndSettle`.
mixin AsyncActionRunner<T extends StatefulWidget> on TickerProviderStateMixin<T>
    implements BouncyControllerHost {
  /// The action to run, or null if there is none.
  Future<void> Function()? get asyncAction;

  /// Called when the action throws. If null, the error is reported to
  /// [FlutterError.reportError].
  void Function(Object error, StackTrace stackTrace)? get asyncOnError;

  /// Describes where an unhandled error came from, for error reports.
  String get asyncErrorContext;

  /// Timing and visibility of the results.
  BouncyButtonFeedback get asyncFeedback;

  /// How long to ignore presses after the action, once the widget is idle
  /// again.
  Duration? get asyncCooldown;

  /// The controller to keep informed, if any.
  BouncyButtonController? get asyncController;

  /// Whether loading is forced from outside, such as by `isLoading`.
  bool get externalLoading => false;

  /// Called when success or error starts showing, for effects such as haptics.
  void onAsyncResult(BouncyButtonStatus status) {}

  /// How long the action may run before it counts as failed, or null for no
  /// limit.
  Duration? get asyncTimeout => null;

  /// Asked before the action runs. The action runs only if it returns true.
  Future<bool> Function()? get asyncConfirm => null;

  /// Whether [asyncConfirm] is waiting for an answer.
  bool _confirming = false;

  /// Completes the future [runAsyncAction] returns, at the end of the action
  /// or when it times out.
  Completer<void>? _runDone;

  BouncyButtonStatus _asyncStatus = BouncyButtonStatus.idle;

  /// Identifies the latest run, so a run that finishes after a reset or a
  /// newer run can't change what is shown.
  int _run = 0;
  Future<void>? _runFuture;
  ExclusivePressOwner? _loadingOwner;

  late final AnimationController _resultHold = AnimationController(
    vsync: this,
  )..addStatusListener(_handleResultHoldStatus);
  late final AnimationController _minLoading = AnimationController(
    vsync: this,
  );
  late final AnimationController _cooldown = AnimationController(vsync: this)
    ..addStatusListener(_handleCooldownStatus);
  late final AnimationController _timeout = AnimationController(vsync: this)
    ..addStatusListener(_handleTimeoutStatus);

  @override
  BouncyButtonStatus get status =>
      externalLoading ? BouncyButtonStatus.loading : _asyncStatus;

  /// Whether presses are being ignored after an action.
  bool get asyncCoolingDown => _cooldown.isAnimating;

  /// Whether another action in a [BouncyExclusiveScope] with
  /// `lockDuringLoading` is running, so this one must wait. Registers a
  /// dependency, so call it from `build`.
  bool watchGroupLock(BuildContext context) =>
      ExclusivePressOwner.watch(context)?.isLockedFor(this) ?? false;

  /// Whether a press should be ignored right now.
  bool get asyncBusy =>
      status != BouncyButtonStatus.idle || asyncCoolingDown || _confirming;

  /// Keeps the controller attached. Call from `initState` and
  /// `didUpdateWidget`, passing the previous controller in the latter.
  void syncAsyncController([BouncyButtonController? previous]) {
    if (!identical(previous, asyncController)) {
      previous?.detach(this);
    }
    asyncController?.attach(this);
  }

  /// Releases resources. Call from `dispose` before `super.dispose()`.
  void disposeAsyncAction() {
    asyncController?.detach(this);
    _endLoading(duringDispose: true);
    _resultHold.dispose();
    _minLoading.dispose();
    _cooldown.dispose();
    _timeout.dispose();
  }

  void _setStatus(BouncyButtonStatus value) {
    if (_asyncStatus == value) {
      return;
    }
    final wasIdle = _asyncStatus == BouncyButtonStatus.idle;
    setState(() => _asyncStatus = value);
    asyncController?.notifyStatus();
    if (!wasIdle && value == BouncyButtonStatus.idle) {
      _startCooldown();
    }
  }

  void _startCooldown() {
    final cooldown = asyncCooldown;
    if (cooldown == null || cooldown <= Duration.zero) {
      return;
    }
    _cooldown
      ..duration = cooldown
      ..forward(from: 0);
    setState(() {});
  }

  void _handleCooldownStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {});
    }
  }

  void _handleResultHoldStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _setStatus(BouncyButtonStatus.idle);
    }
  }

  void _handleTimeoutStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed ||
        !mounted ||
        this.status != BouncyButtonStatus.loading) {
      return;
    }
    final limit = _timeout.duration!;
    // The action keeps running, but its result no longer counts. An error it
    // throws later is still reported.
    _run++;
    _minLoading.stop();
    _finishRun();
    _reportError(
      TimeoutException('The action did not finish within $limit.', limit),
      StackTrace.current,
    );
    _endLoading();
    _showResult(BouncyButtonStatus.error);
  }

  void _finishRun() {
    final done = _runDone;
    _runDone = null;
    if (done != null && !done.isCompleted) {
      done.complete();
    }
  }

  /// Asks [asyncConfirm], if set, while ignoring presses. Returns whether to
  /// go ahead. If it throws, the error is reported and the answer is no.
  Future<bool> confirmFirst() async {
    final confirm = asyncConfirm;
    if (confirm == null) {
      return true;
    }
    if (_confirming) {
      return false;
    }
    final run = _run;
    setState(() => _confirming = true);
    var confirmed = false;
    try {
      confirmed = await confirm();
    } catch (error, stackTrace) {
      _reportError(error, stackTrace);
    }
    if (!mounted || run != _run) {
      return false;
    }
    setState(() => _confirming = false);
    return confirmed;
  }

  void _endLoading({bool duringDispose = false}) {
    _loadingOwner?.endLoading(this, duringDispose: duringDispose);
    _loadingOwner = null;
  }

  /// Runs the action, unless one is running, a result is showing, the
  /// cooldown is active, or another action in the scope holds the lock.
  ///
  /// Returns a future that completes when the action finishes.
  Future<void> runAsyncAction() {
    final action = asyncAction;
    if (status == BouncyButtonStatus.loading) {
      return _runFuture ?? Future<void>.value();
    }
    if (action == null || asyncBusy) {
      return Future<void>.value();
    }
    if (asyncConfirm != null) {
      return _confirmThenStart(action);
    }
    return _start(action);
  }

  Future<void> _confirmThenStart(Future<void> Function() action) async {
    if (!await confirmFirst() || asyncBusy) {
      return;
    }
    await _start(action);
  }

  Future<void> _start(Future<void> Function() action) {
    final owner = ExclusivePressOwner.maybeOf(context);
    if (owner != null && !owner.beginLoading(this)) {
      return Future<void>.value();
    }
    _loadingOwner = owner;
    final done = _runDone = Completer<void>();
    // An error here can only come from onError itself, and is passed on.
    _execute(action).then(
      (_) {
        if (!done.isCompleted) {
          done.complete();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!done.isCompleted) {
          done.completeError(error, stackTrace);
        }
      },
    );
    return _runFuture = done.future;
  }

  Future<void> _execute(Future<void> Function() action) async {
    final run = ++_run;
    final feedback = asyncFeedback;
    _setStatus(BouncyButtonStatus.loading);
    if (feedback.minLoadingDuration > Duration.zero) {
      _minLoading
        ..duration = feedback.minLoadingDuration
        ..forward(from: 0);
    }
    final timeout = asyncTimeout;
    if (timeout != null && timeout > Duration.zero) {
      _timeout
        ..duration = timeout
        ..forward(from: 0);
    }
    Object? error;
    StackTrace? stackTrace;
    try {
      // Called inside the try, so a synchronous throw is caught too.
      await action();
    } catch (caught, trace) {
      error = caught;
      stackTrace = trace;
    }
    if (error != null) {
      _reportError(error, stackTrace!);
    }
    if (!mounted || run != _run) {
      return;
    }
    _timeout.stop();
    // Keep loading on screen for the minimum time.
    if (_minLoading.isAnimating) {
      try {
        await _minLoading.forward().orCancel;
      } on TickerCanceled {
        return;
      }
      if (!mounted || run != _run) {
        return;
      }
    }
    _endLoading();
    _showResult(
      error == null ? BouncyButtonStatus.success : BouncyButtonStatus.error,
    );
  }

  void _reportError(Object error, StackTrace stackTrace) {
    final onError = asyncOnError;
    if (onError != null) {
      onError(error, stackTrace);
      return;
    }
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'bouncy_button',
        context: ErrorDescription(asyncErrorContext),
      ),
    );
  }

  void _showResult(BouncyButtonStatus result) {
    final feedback = asyncFeedback;
    final show = result == BouncyButtonStatus.success
        ? feedback.showSuccess
        : feedback.showError;
    if (!show) {
      _setStatus(BouncyButtonStatus.idle);
      return;
    }
    _setStatus(result);
    onAsyncResult(result);
    _resultHold
      ..duration = feedback.resultDuration
      ..forward(from: 0);
  }

  @override
  void reset() {
    _run++;
    _runFuture = null;
    _runDone = null;
    _resultHold.stop();
    _minLoading.stop();
    _cooldown.stop();
    _timeout.stop();
    _endLoading();
    setState(() {
      _asyncStatus = BouncyButtonStatus.idle;
      _confirming = false;
    });
    asyncController?.notifyStatus();
  }
}
