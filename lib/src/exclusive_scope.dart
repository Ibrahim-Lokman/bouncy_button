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
/// It is opt-in because some layouts need simultaneous presses, such as game
/// controls or fast typing on a keypad. Keyboard and screen reader activation
/// are not affected.
class BouncyExclusiveScope extends StatefulWidget {
  /// Creates an exclusive scope.
  const BouncyExclusiveScope({super.key, required this.child});

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<BouncyExclusiveScope> createState() => _BouncyExclusiveScopeState();
}

class _BouncyExclusiveScopeState extends State<BouncyExclusiveScope> {
  final ExclusivePressOwner _owner = ExclusivePressOwner();

  @override
  Widget build(BuildContext context) {
    return _ExclusiveInherited(owner: _owner, child: widget.child);
  }
}

class _ExclusiveInherited extends InheritedWidget {
  const _ExclusiveInherited({required this.owner, required super.child});

  final ExclusivePressOwner owner;

  @override
  bool updateShouldNotify(_ExclusiveInherited oldWidget) =>
      owner != oldWidget.owner;
}

/// Tracks which control holds the press in a [BouncyExclusiveScope].
class ExclusivePressOwner {
  Object? _holder;

  /// Returns the owner for [context], if it is inside a scope.
  static ExclusivePressOwner? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<_ExclusiveInherited>()?.owner;
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
}
