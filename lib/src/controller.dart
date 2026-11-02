import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'enums.dart';

/// What a [BouncyButtonController] drives. Implemented by the widgets that
/// accept a controller.
abstract interface class BouncyControllerHost {
  /// The current status.
  BouncyButtonStatus get status;

  /// Runs the action, as if pressed.
  Future<void> press();

  /// Returns to idle at once.
  void reset();
}

/// Controls a `BouncyButton` or `BouncyAsyncBuilder` from code.
///
/// ```dart
/// final controller = BouncyButtonController();
///
/// BouncyButton(
///   controller: controller,
///   onPressedAsync: save,
///   child: const Text('Save'),
/// )
///
/// // Elsewhere, such as from a keyboard shortcut:
/// await controller.press();
/// ```
///
/// Listen to it to follow the [status]. A controller can be attached to one
/// widget at a time. Dispose it when it is no longer needed.
class BouncyButtonController extends ChangeNotifier {
  BouncyControllerHost? _host;
  BouncyButtonStatus _lastStatus = BouncyButtonStatus.idle;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Whether the controller is attached to a widget.
  bool get isAttached => _host != null;

  /// The widget's current status, or [BouncyButtonStatus.idle] when detached.
  BouncyButtonStatus get status => _host?.status ?? BouncyButtonStatus.idle;

  /// Runs the action, as if the button were pressed, including its press
  /// animation.
  ///
  /// The returned future completes when the action finishes. If the button is
  /// already loading, it completes when that action finishes instead. It does
  /// nothing if the button is disabled, waiting out a cooldown, or detached.
  Future<void> press() => _host?.press() ?? Future<void>.value();

  /// Returns the button to idle at once, ending any success or error being
  /// shown.
  ///
  /// An action that is still running continues, but its result is ignored.
  void reset() => _host?.reset();

  /// Connects [host]. Called by the widget.
  void attach(BouncyControllerHost host) {
    assert(
      _host == null || identical(_host, host),
      'A BouncyButtonController can only be attached to one widget at a time.',
    );
    _host = host;
    notifyStatus();
  }

  /// Disconnects [host], if it is the attached one. Called by the widget.
  ///
  /// Listeners are told after the current frame, because the widget may be
  /// being removed, when rebuilding other widgets isn't allowed.
  void detach(BouncyControllerHost host) {
    if (!identical(_host, host)) {
      return;
    }
    _host = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        notifyStatus();
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  /// Tells listeners the status may have changed. Called by the widget.
  void notifyStatus() {
    final current = status;
    if (current != _lastStatus) {
      _lastStatus = current;
      notifyListeners();
    }
  }
}
