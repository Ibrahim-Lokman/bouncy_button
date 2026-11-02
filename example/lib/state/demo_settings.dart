import 'package:flutter/material.dart';

/// Everything the Settings screen controls.
///
/// Values live in memory, so a restart returns to these defaults.
class DemoSettings extends ChangeNotifier {
  DemoSettings({
    ThemeMode themeMode = ThemeMode.system,
    double textScale = 1.0,
    bool rtl = false,
    bool reduceMotion = false,
    bool haptics = true,
    bool sound = false,
    Duration latency = const Duration(milliseconds: 800),
    double failureRate = 0.0,
    bool offline = false,
    bool emptyCatalog = false,
  })  : _themeMode = themeMode,
        _textScale = textScale,
        _rtl = rtl,
        _reduceMotion = reduceMotion,
        _haptics = haptics,
        _sound = sound,
        _latency = latency,
        _failureRate = failureRate,
        _offline = offline,
        _emptyCatalog = emptyCatalog;

  ThemeMode _themeMode;
  double _textScale;
  bool _rtl;
  bool _reduceMotion;
  bool _haptics;
  bool _sound;
  Duration _latency;
  double _failureRate;
  bool _offline;
  bool _emptyCatalog;

  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) => _update(() => _themeMode = value);

  /// Multiplies system text size, to check layouts at large sizes.
  double get textScale => _textScale;
  set textScale(double value) => _update(() => _textScale = value);

  bool get rtl => _rtl;
  set rtl(bool value) => _update(() => _rtl = value);

  /// Simulates the system "reduce motion" setting.
  bool get reduceMotion => _reduceMotion;
  set reduceMotion(bool value) => _update(() => _reduceMotion = value);

  bool get haptics => _haptics;
  set haptics(bool value) => _update(() => _haptics = value);

  /// Plays the system click on presses, where the platform has one.
  bool get sound => _sound;
  set sound(bool value) => _update(() => _sound = value);

  /// How long each mock request takes.
  Duration get latency => _latency;
  set latency(Duration value) => _update(() => _latency = value);

  /// The chance of each mock request failing, from 0 to 1.
  double get failureRate => _failureRate;
  set failureRate(double value) => _update(() => _failureRate = value);

  /// Makes every mock request fail with a network error.
  bool get offline => _offline;
  set offline(bool value) => _update(() => _offline = value);

  /// Makes the mock catalog return no products.
  bool get emptyCatalog => _emptyCatalog;
  set emptyCatalog(bool value) => _update(() => _emptyCatalog = value);

  void _update(VoidCallback change) {
    change();
    notifyListeners();
  }
}
