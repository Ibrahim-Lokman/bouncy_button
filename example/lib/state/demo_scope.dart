import 'package:flutter/widgets.dart';

import '../data/mock_backend.dart';
import 'demo_settings.dart';
import 'event_log.dart';

/// Gives the demo's screens access to its settings, backend, and log.
class DemoScope extends InheritedNotifier<DemoSettings> {
  const DemoScope({
    super.key,
    required DemoSettings settings,
    required this.backend,
    required this.log,
    required super.child,
  }) : super(notifier: settings);

  final MockBackend backend;
  final EventLog log;

  DemoSettings get settings => notifier!;

  /// Returns the scope and rebuilds [context] when settings change.
  static DemoScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DemoScope>()!;

  /// Returns the scope without rebuilding, for use in callbacks.
  static DemoScope read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DemoScope>()!;
}
