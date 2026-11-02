import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Provides a [BouncyButtonTheme] to the buttons below it without using the
/// Material `Theme`.
///
/// Use it in apps that use `package:material_ui`, whose `Theme` and
/// `ThemeExtension` are separate from the Flutter SDK's, so a
/// [BouncyButtonTheme] can't be added to their theme's extensions. It works in
/// any other app too.
///
/// ```dart
/// BouncyButtonScope(
///   theme: const BouncyButtonTheme(
///     primaryStyle: BouncyButtonStyle(backgroundColor: Colors.teal),
///   ),
///   child: child,
/// )
/// ```
///
/// The nearest scope replaces any [BouncyButtonTheme] from the Material theme.
/// A style passed directly to a button still wins over both.
class BouncyButtonScope extends InheritedWidget {
  /// Creates a scope.
  const BouncyButtonScope({
    super.key,
    required this.theme,
    required super.child,
  });

  /// The theme for buttons below this widget.
  final BouncyButtonTheme theme;

  /// Returns the theme of the nearest scope, or null if there is none.
  static BouncyButtonTheme? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BouncyButtonScope>()
        ?.theme;
  }

  @override
  bool updateShouldNotify(BouncyButtonScope oldWidget) =>
      theme != oldWidget.theme;
}
