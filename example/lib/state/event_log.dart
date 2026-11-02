import 'package:flutter/foundation.dart';

/// One line in the on-screen event log.
@immutable
class LogEntry {
  const LogEntry(this.time, this.message);

  final DateTime time;
  final String message;
}

/// Records what the demo's buttons did, so it can be seen without a console.
class EventLog extends ChangeNotifier {
  static const int _maxEntries = 100;

  final List<LogEntry> _entries = [];

  /// The entries, newest first.
  List<LogEntry> get entries => List.unmodifiable(_entries);

  void add(String message) {
    _entries.insert(0, LogEntry(DateTime.now(), message));
    if (_entries.length > _maxEntries) {
      _entries.removeLast();
    }
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
