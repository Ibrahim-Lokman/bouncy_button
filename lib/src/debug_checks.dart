import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Whether bouncy_button prints warnings about common button mistakes in
/// debug builds.
///
/// The checks look for problems that make buttons hard to use, such as:
///
/// - An icon-only button with no label, which screen readers can't name.
/// - A `semanticLabel` that doesn't contain the visible text, which breaks
///   voice control.
/// - Text with too little contrast against the button.
/// - A tap area smaller than 48 by 48, or 44 by 44 on Apple platforms.
/// - Another tappable widget inside a button.
/// - English screen reader labels in an app using another language.
///
/// They only run in debug mode, so release builds don't include them. Each
/// warning is printed once. Set this to false to turn them all off, for
/// example at the start of `main`.
bool debugBouncyChecksEnabled = true;

final Set<String> _reported = <String>{};

/// Prints [message] once for each [key], if [debugBouncyChecksEnabled].
///
/// Call it only inside an `assert`, so release builds leave it out.
void debugBouncyWarn(String key, String message) {
  if (!debugBouncyChecksEnabled || !_reported.add(key)) {
    return;
  }
  debugPrint(
    'bouncy_button: $message\n'
    'To turn these warnings off, set debugBouncyChecksEnabled = false.',
  );
}

/// Forgets which warnings were printed, so that tests can see them again.
@visibleForTesting
void debugResetBouncyWarnings() => _reported.clear();

/// The contrast ratio between two opaque colors, as WCAG defines it: from 1
/// for the same color to 21 for black on white.
double contrastRatio(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = math.max(first, second);
  final darker = math.min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Whether WCAG counts [style] as large text, which needs less contrast:
/// at least 24 pixels, or 18.66 pixels and bold.
bool debugIsLargeText(TextStyle? style) {
  final size = style?.fontSize ?? 14;
  final bold = (style?.fontWeight?.value ?? 400) >= 700;
  return size >= 24 || (size >= 18.66 && bold);
}

/// The text shown below [context], with its style, skipping icons, which
/// draw their glyph as text.
List<(String, TextStyle?)> debugVisibleTexts(BuildContext context) {
  final texts = <(String, TextStyle?)>[];
  void visit(Element element) {
    final widget = element.widget;
    if (widget is Icon) {
      return;
    }
    if (widget is RichText) {
      final text = widget.text
          .toPlainText(includeSemanticsLabels: false)
          .replaceAll('￼', '')
          .trim();
      if (text.isNotEmpty) {
        texts.add((text, widget.text.style));
      }
      return;
    }
    element.visitChildren(visit);
  }

  (context as Element).visitChildren(visit);
  return texts;
}

/// Whether there is a widget that handles taps below [context], such as a
/// button, an InkWell, a GestureDetector, or a text field.
bool debugContainsTappable(BuildContext context) {
  var found = false;
  void visit(Element element) {
    if (found) {
      return;
    }
    if (element.widget is RawGestureDetector) {
      found = true;
      return;
    }
    element.visitChildren(visit);
  }

  (context as Element).visitChildren(visit);
  return found;
}

/// The smallest recommended tap area on the current platform: 44 on Apple
/// platforms, as Apple's guidelines say, and 48 elsewhere, as Material's do.
double debugMinTapTarget() => switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => 44,
      _ => 48,
    };
