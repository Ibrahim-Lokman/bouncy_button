/// Test helpers for apps that use bouncy_button.
///
/// Import it in your widget tests only:
///
/// ```dart
/// import 'package:bouncy_button/testing.dart';
/// ```
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks that the button [finder] finds can be used by everyone, and fails
/// the test with an explanation if not.
///
/// It checks that:
///
/// - Screen readers find a button with a label or tooltip.
/// - Every tappable on the screen is at least 48 by 48 on Android and 44 by
///   44 on iOS, and has a label. These are Flutter's
///   [androidTapTargetGuideline], [iOSTapTargetGuideline], and
///   [labeledTapTargetGuideline].
/// - Text on the screen has enough contrast, with Flutter's
///   [textContrastGuideline]. Set [checkContrast] to false to skip it.
///
/// If [pressCount] is given, it must return how many times the button's
/// action has run. The helper then also checks that a quick double tap and a
/// held Enter key each run the action only once. For a button with a plain
/// `onPressed`, that needs a `cooldown`. Use it on buttons whose action keeps
/// the button on screen, rather than opening a page or dialog.
///
/// ```dart
/// testWidgets('the pay button is accessible', (tester) async {
///   var payments = 0;
///   await tester.pumpWidget(MyCheckout(onPay: () async => payments++));
///   await expectAccessibleButton(
///     tester,
///     find.widgetWithText(BouncyButton, 'Pay'),
///     pressCount: () => payments,
///   );
/// });
/// ```
///
/// The guidelines look at the whole screen, not only this button, so a
/// problem elsewhere on the screen also fails the test.
Future<void> expectAccessibleButton(
  WidgetTester tester,
  Finder finder, {
  int Function()? pressCount,
  bool checkContrast = true,
}) async {
  final handle = tester.ensureSemantics();
  try {
    await tester.pump();
    expect(finder, findsOneWidget, reason: 'The finder must find one button.');

    final node = _buttonNode(tester, finder);
    expect(
      node,
      isNotNull,
      reason: 'Screen readers should announce it as a button, but found no '
          'button semantics in or around it.',
    );
    final data = node!.getSemanticsData();
    expect(
      data.label.trim().isNotEmpty || data.tooltip.trim().isNotEmpty,
      isTrue,
      reason: 'Screen readers have no label to read for this button. Give it '
          'text, a semanticLabel, or a tooltip.',
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    if (checkContrast) {
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }

    if (pressCount == null) {
      return;
    }

    // A quick double tap, as people often do out of habit.
    var before = pressCount();
    await tester.tap(finder, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder, warnIfMissed: false);
    await tester.pumpAndSettle();
    final afterTaps = pressCount() - before;
    expect(
      afterTaps,
      1,
      reason: 'A quick double tap ran the action $afterTaps times. Add a '
          'cooldown, or use onPressedAsync, which ignores taps while it runs.',
    );

    // A held Enter key, which sends repeat events.
    final focusNode = _focusNodeOf(tester, finder);
    focusNode.requestFocus();
    await tester.pump();
    before = pressCount();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    final afterKey = pressCount() - before;
    focusNode.unfocus();
    await tester.pumpAndSettle();
    expect(
      afterKey,
      1,
      reason: 'Holding Enter on the focused button ran the action $afterKey '
          'times, but it should run once.',
    );
  } finally {
    handle.dispose();
  }
}

/// The semantics node of the button that [finder] finds, is inside of, or
/// contains, as with a button wrapped in a tooltip.
SemanticsNode? _buttonNode(WidgetTester tester, Finder finder) {
  // hasFlag's replacement does not exist on the minimum Flutter version.
  // ignore: deprecated_member_use
  bool isButton(SemanticsNode node) => node.hasFlag(SemanticsFlag.isButton);
  final around = tester.getSemantics(finder);
  if (isButton(around)) {
    return around;
  }
  SemanticsNode? found;
  void visit(Element element) {
    final semantics = element.renderObject?.debugSemantics;
    if (semantics != null && isButton(semantics)) {
      found = semantics;
      return;
    }
    element.visitChildren((child) {
      if (found == null) {
        visit(child);
      }
    });
  }

  visit(tester.element(finder));
  return found;
}

/// The focus node of the button that [finder] finds, or is inside of.
FocusNode _focusNodeOf(WidgetTester tester, Finder finder) {
  // Some Focus widgets, such as the one Shortcuts adds, have no node.
  bool hasNode(Widget widget) => widget is Focus && widget.focusNode != null;
  final inside = find.descendant(
    of: finder,
    matching: find.byWidgetPredicate(hasNode),
  );
  if (inside.evaluate().isNotEmpty) {
    return tester.widget<Focus>(inside.first).focusNode!;
  }
  FocusNode? nearest;
  tester.element(finder).visitAncestorElements((element) {
    if (hasNode(element.widget)) {
      nearest = (element.widget as Focus).focusNode;
      return false;
    }
    return true;
  });
  if (nearest == null) {
    throw TestFailure('Could not find the focus node of the button.');
  }
  return nearest!;
}
