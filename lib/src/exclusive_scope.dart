import 'package:flutter/widgets.dart';

/// Lets only one control below it be pressed at a time.
///
/// Flutter tracks each finger separately, so by default two fingers can press
/// two buttons at once and both fire. Inside this scope, a press that starts
/// while another control is held is ignored until that finger lifts, including
/// its tap and long press. Use it where double activation would be a problem,
/// such as a row of navigation buttons:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => BouncyExclusiveScope(child: child!),
/// )
/// ```
///
/// With [lockDuringLoading], it also lets only one async action run at a
/// time. While one `BouncyButton.onPressedAsync` or `BouncyAsyncBuilder`
/// action below it is loading, the other async buttons in the scope are
/// disabled. This suits screens with several actions that must not overlap,
/// such as "Sign in with Google" and "Sign in with Apple".
///
/// It is opt-in because some layouts need simultaneous presses, such as game
/// controls or fast typing on a keypad. Keyboard and screen reader activation
/// are not affected by the press lock.
class BouncyExclusiveScope extends StatefulWidget {
  /// Creates an exclusive scope.
  const BouncyExclusiveScope({
    super.key,
    this.lockDuringLoading = false,
    required this.child,
  });

  /// Whether async buttons below wait for each other: while one is loading,
  /// the others are disabled.
  final bool lockDuringLoading;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<BouncyExclusiveScope> createState() => _BouncyExclusiveScopeState();
}

class _BouncyExclusiveScopeState extends State<BouncyExclusiveScope> {
  final ExclusivePressOwner _owner = ExclusivePressOwner();

  @override
  void initState() {
    super.initState();
    _owner._lockDuringLoading = widget.lockDuringLoading;
  }

  @override
  void didUpdateWidget(BouncyExclusiveScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _owner._setLockDuringLoading(widget.lockDuringLoading);
  }

  @override
  void dispose() {
    _owner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ExclusiveInherited(owner: _owner, child: widget.child);
  }
}

class _ExclusiveInherited extends InheritedNotifier<ExclusivePressOwner> {
  const _ExclusiveInherited({
    required ExclusivePressOwner owner,
    required super.child,
  }) : super(notifier: owner);
}

/// Tracks which control holds the press, and which action is loading, in a
/// [BouncyExclusiveScope].
class ExclusivePressOwner extends ChangeNotifier {
  Object? _holder;
  Object? _loadingHolder;
  bool _lockDuringLoading = false;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Notifies after the current frame. Used when the tree is locked, such as
  /// while a widget is being disposed.
  void _notifyAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        notifyListeners();
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// Returns the owner for [context], if it is inside a scope, without
  /// rebuilding [context] when the lock changes.
  static ExclusivePressOwner? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<_ExclusiveInherited>()
        ?.notifier;
  }

  /// Returns the owner for [context], if it is inside a scope, and rebuilds
  /// [context] when another action starts or stops loading.
  static ExclusivePressOwner? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ExclusiveInherited>()
        ?.notifier;
  }

  void _setLockDuringLoading(bool value) {
    if (_lockDuringLoading == value) {
      return;
    }
    _lockDuringLoading = value;
    if (!value) {
      _loadingHolder = null;
    }
    notifyListeners();
  }

  /// Takes the press for [holder]. Returns false if another control holds it.
  bool claim(Object holder) {
    if (_holder != null && !identical(_holder, holder)) {
      return false;
    }
    _holder = holder;
    return true;
  }

  /// Gives up the press, if [holder] has it.
  void release(Object holder) {
    if (identical(_holder, holder)) {
      _holder = null;
    }
  }

  /// Whether [holder] must wait because another action is loading.
  bool isLockedFor(Object holder) =>
      _lockDuringLoading &&
      _loadingHolder != null &&
      !identical(_loadingHolder, holder);

  /// Records that [holder]'s action started loading. Returns false if another
  /// action is loading, in which case [holder] must not start.
  bool beginLoading(Object holder) {
    if (!_lockDuringLoading) {
      return true;
    }
    if (isLockedFor(holder)) {
      return false;
    }
    if (_loadingHolder == null) {
      _loadingHolder = holder;
      notifyListeners();
    }
    return true;
  }

  /// Records that [holder]'s action stopped loading.
  ///
  /// Set [duringDispose] when [holder] is being removed from the tree, where
  /// rebuilding other widgets isn't allowed until the frame ends.
  void endLoading(Object holder, {bool duringDispose = false}) {
    if (!identical(_loadingHolder, holder)) {
      return;
    }
    _loadingHolder = null;
    if (duringDispose) {
      _notifyAfterFrame();
    } else {
      notifyListeners();
    }
  }
}
