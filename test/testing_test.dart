import 'package:bouncy_button/bouncy_button.dart';
import 'package:bouncy_button/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

/// Runs [check], which must fail, and returns the failure's message.
///
/// The helper makes tester calls itself, so it can't run inside expectLater,
/// which is guarded too.
Future<String> _failureOf(Future<void> Function() check) async {
  try {
    await check();
  } on TestFailure catch (failure) {
    return failure.message ?? '';
  }
  fail('Expected the check to fail.');
}

void main() {
  setUp(() => debugBouncyChecksEnabled = false);
  tearDown(() => debugBouncyChecksEnabled = true);

  group('expectAccessibleButton', () {
    testWidgets('passes for a button with a cooldown', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            cooldown: const Duration(milliseconds: 500),
            child: const Text('Open'),
          ),
        ),
      );
      await expectAccessibleButton(
        tester,
        find.text('Open'),
        pressCount: () => presses,
      );
      expect(presses, 2);
    });

    testWidgets('passes for an async button', (tester) async {
      var payments = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async {
              await Future<void>.delayed(const Duration(milliseconds: 300));
              payments++;
            },
            child: const Text('Pay'),
          ),
        ),
      );
      await expectAccessibleButton(
        tester,
        find.byType(BouncyButton),
        pressCount: () => payments,
      );
    });

    testWidgets('passes for an icon button', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton.icon(
            onPressed: () {},
            tooltip: 'Share',
            icon: const Icon(Icons.share),
          ),
        ),
      );
      await expectAccessibleButton(tester, find.byType(BouncyButton));
    });

    testWidgets('fails when a double tap runs twice', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            child: const Text('Open'),
          ),
        ),
      );
      final message = await _failureOf(
        () => expectAccessibleButton(
          tester,
          find.text('Open'),
          pressCount: () => presses,
        ),
      );
      expect(message, contains('A quick double tap ran the action 2 times'));
    });

    testWidgets('fails for an icon with no label', (tester) async {
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Icon(Icons.share))),
      );
      final message = await _failureOf(
        () => expectAccessibleButton(tester, find.byType(BouncyButton)),
      );
      expect(message, contains('no label to read'));
    });

    testWidgets('fails for a small button', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: const BouncyButtonStyle(
              height: 24,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Go'),
          ),
        ),
      );
      final message = await _failureOf(
        () => expectAccessibleButton(tester, find.byType(BouncyButton)),
      );
      expect(message, contains('at least Size(48.0, 48.0)'));
    });

    testWidgets('fails for low contrast, unless skipped', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: const BouncyButtonStyle(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buy'),
          ),
        ),
      );
      final message = await _failureOf(
        () => expectAccessibleButton(tester, find.byType(BouncyButton)),
      );
      expect(message, contains('contrast'));
      await expectAccessibleButton(
        tester,
        find.byType(BouncyButton),
        checkContrast: false,
      );
    });
  });
}
