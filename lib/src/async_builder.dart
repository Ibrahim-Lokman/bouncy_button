import 'dart:async' show TimeoutException;

import 'package:flutter/widgets.dart';

import 'async_action.dart';
import 'controller.dart';
import 'enums.dart';
import 'feedback.dart';

/// Builds a widget with the guarded callback and current status that
/// [BouncyAsyncBuilder] provides.
typedef BouncyAsyncWidgetBuilder = Widget Function(
  BuildContext context,
  VoidCallback? onPressed,
  BouncyButtonStatus status,
);

/// Adds double-tap protection and loading, success, and error states to any
/// button, including ones from Material, Cupertino, or your own design system.
///
/// ```dart
/// BouncyAsyncBuilder(
///   onPressed: () => api.placeOrder(cart),
///   builder: (context, onPressed, status) => ElevatedButton(
///     onPressed: onPressed,
///     child: status == BouncyButtonStatus.loading
///         ? const CircularProgressIndicator()
///         : const Text('Pay'),
///   ),
/// )
/// ```
///
/// While the action runs, the callback ignores further presses, so a payment
/// or form can't be sent twice. The block takes effect immediately, even for
/// two taps in the same frame. Errors go to [onError], or to
/// [FlutterError.reportError], and are never silently lost.
///
/// By default the callback stays non-null while busy, so the button keeps its
/// enabled look and keyboard focus. Use the status to show progress. Set
/// [disableWhileBusy] to pass null instead, which makes most buttons look
/// disabled but drops their keyboard focus.
///
/// It needs no Material code. For a complete button with these states built
/// in, use `BouncyButton.onPressedAsync`.
class BouncyAsyncBuilder extends StatefulWidget {
  /// Creates an async builder.
  const BouncyAsyncBuilder({
    super.key,
    required this.onPressed,
    required this.builder,
    this.onError,
    this.feedback,
    this.cooldown,
    this.controller,
    this.disableWhileBusy = false,
    this.announceStatus = true,
    this.timeout,
    this.confirm,
  });

  /// The action. If null, [builder] receives a null callback.
  final Future<void> Function()? onPressed;

  /// Builds the button from the guarded callback and the current status.
  final BouncyAsyncWidgetBuilder builder;

  /// Called when [onPressed] throws. If null, the error is reported to
  /// [FlutterError.reportError].
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// How long success and error last, the minimum loading time, and the
  /// labels screen readers announce. Its builders are not used here.
  final BouncyButtonFeedback? feedback;

  /// How long to ignore presses after the widget is ready again, after any
  /// success or error. Errors count too.
  final Duration? cooldown;

  /// Controls the action from code: run it, reset it, or follow its status.
  final BouncyButtonController? controller;

  /// Whether [builder] receives a null callback while busy, instead of one
  /// that ignores presses. Most buttons then look disabled, but lose keyboard
  /// focus.
  final bool disableWhileBusy;

  /// Whether screen readers announce loading, success, and error.
  ///
  /// The announcement is merged into the semantics of what [builder] returns,
  /// which suits a single button. Set this to false if [builder] returns
  /// several controls.
  final bool announceStatus;

  /// How long [onPressed] may run before it counts as failed, so a request
  /// that hangs doesn't keep the widget busy forever.
  ///
  /// [onError] then receives a [TimeoutException], and presses work again.
  /// The action keeps running, but its result is ignored. An error it throws
  /// later is still reported. If null, there is no limit.
  final Duration? timeout;

  /// Asked before [onPressed] runs, such as to show a confirmation dialog.
  /// The action runs only if it returns true. Presses are ignored while it
  /// waits, and the status stays idle. If it throws, the error goes to
  /// [onError] and the action doesn't run.
  final Future<bool> Function()? confirm;

  @override
  State<BouncyAsyncBuilder> createState() => _BouncyAsyncBuilderState();
}

class _BouncyAsyncBuilderState extends State<BouncyAsyncBuilder>
    with TickerProviderStateMixin, AsyncActionRunner<BouncyAsyncBuilder> {
  bool _groupLocked = false;

  BouncyButtonFeedback get _feedback =>
      widget.feedback ?? const BouncyButtonFeedback();

  @override
  Future<void> Function()? get asyncAction => widget.onPressed;

  @override
  void Function(Object error, StackTrace stackTrace)? get asyncOnError =>
      widget.onError;

  @override
  String get asyncErrorContext => 'while running BouncyAsyncBuilder.onPressed';

  @override
  BouncyButtonFeedback get asyncFeedback => _feedback;

  @override
  Duration? get asyncCooldown => widget.cooldown;

  @override
  BouncyButtonController? get asyncController => widget.controller;

  @override
  Duration? get asyncTimeout => widget.timeout;

  @override
  Future<bool> Function()? get asyncConfirm => widget.confirm;

  @override
  void initState() {
    super.initState();
    syncAsyncController();
  }

  @override
  void didUpdateWidget(BouncyAsyncBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncAsyncController(oldWidget.controller);
  }

  @override
  void dispose() {
    disposeAsyncAction();
    super.dispose();
  }

  @override
  Future<void> press() {
    if (_groupLocked) {
      return Future<void>.value();
    }
    return runAsyncAction();
  }

  void _handlePressed() {
    if (!_groupLocked) {
      runAsyncAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (widget.announceStatus && widget.onPressed != null) {
        debugCheckFeedbackLabels(context, 'BouncyAsyncBuilder');
      }
      return true;
    }());
    _groupLocked = watchGroupLock(context);
    final hasAction = widget.onPressed != null;
    final blocked = asyncBusy || _groupLocked;
    final callback = !hasAction || (widget.disableWhileBusy && blocked)
        ? null
        : _handlePressed;
    final child = widget.builder(context, callback, status);
    if (!widget.announceStatus) {
      return child;
    }
    final label = _feedback.labelFor(status);
    // Always wrapped, so the child keeps its state as the status changes.
    return MergeSemantics(
      child: Semantics(
        value: label,
        liveRegion: label != null,
        child: child,
      ),
    );
  }
}
