import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// The debug warnings bouncy_button printed, kept so the Features tour can
/// show them on screen instead of only in the console.
class WarningLog extends ValueNotifier<List<String>> {
  WarningLog() : super(const []);

  void add(String warning) {
    // Warnings can be printed while widgets build, when listeners must not
    // rebuild, so those wait for the end of the frame.
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) => value = [...value, warning]);
    } else {
      value = [...value, warning];
    }
  }
}

/// The warnings shown by the "Catch mistakes early" demo.
final WarningLog bouncyWarnings = WarningLog();

/// Copies bouncy_button's debug warnings into [bouncyWarnings], while still
/// printing them. Returns a function that undoes it.
VoidCallback captureBouncyWarnings() {
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null && message.startsWith('bouncy_button: ')) {
      bouncyWarnings.add(message);
    }
    original(message, wrapWidth: wrapWidth);
  };
  return () => debugPrint = original;
}
