import 'dart:async';

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

final Finder _spinner = find.byType(CircularProgressIndicator);
final Finder _tick = find.byIcon(Icons.check_rounded);
final Finder _errorIcon = find.byIcon(Icons.error_outline_rounded);

/// Turns on the system setting that removes animations, such as Remove
/// animations on Android. Flutter then shortens ordinary animations to 5%.
void _disableSystemAnimations(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void main() {
  group('with system animations turned off', () {
    testWidgets('a cooldown keeps its full length', (tester) async {
      _disableSystemAnimations(tester);
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            cooldown: const Duration(milliseconds: 600),
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      expect(presses, 1);
    });

    testWidgets('a pressable cooldown keeps its full length', (tester) async {
      _disableSystemAnimations(tester);
      var taps = 0;
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () => taps++,
            cooldown: const Duration(milliseconds: 600),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.tap(find.byType(BouncyPressable));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byType(BouncyPressable));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('success stays on screen, and loading lasts its minimum',
        (tester) async {
      _disableSystemAnimations(tester);
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async {},
            feedback: const BouncyButtonFeedback(
              minLoadingDuration: Duration(milliseconds: 400),
              resultDuration: Duration(milliseconds: 1200),
            ),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(_spinner, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));
      expect(_tick, findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('a timeout keeps its full length', (tester) async {
      _disableSystemAnimations(tester);
      final errors = <Object>[];
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => Completer<void>().future,
            onError: (error, _) => errors.add(error),
            timeout: const Duration(seconds: 10),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(errors, isEmpty);
      await tester.pump(const Duration(seconds: 5));
      expect(errors.single, isA<TimeoutException>());
      await tester.pumpAndSettle();
    });
  });

  testWidgets('a timeout fires while the button is off screen', (tester) async {
    final errors = <Object>[];
    Widget build({required bool covered}) => _app(
          // As when the action opens a page over the button.
          TickerMode(
            enabled: !covered,
            child: BouncyButton(
              onPressedAsync: () => Completer<void>().future,
              onError: (error, _) => errors.add(error),
              timeout: const Duration(seconds: 2),
              child: const Text('Pay'),
            ),
          ),
        );
    await tester.pumpWidget(build(covered: false));
    await tester.tap(find.text('Pay'));
    await tester.pump();
    await tester.pumpWidget(build(covered: true));
    await tester.pump(const Duration(seconds: 2));
    expect(errors.single, isA<TimeoutException>());
    await tester.pumpWidget(build(covered: false));
    await tester.pumpAndSettle();
  });

  group('an onError that throws', () {
    testWidgets('is reported, and the button recovers', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async {
              calls++;
              throw StateError('request failed');
            },
            onError: (error, _) => throw ArgumentError('handler bug'),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(tester.takeException(), isA<ArgumentError>());
      await tester.pump();
      expect(_errorIcon, findsOneWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(tester.takeException(), isA<ArgumentError>());
      expect(calls, 2);
      await tester.pumpAndSettle();
    });

    testWidgets('after a timeout still frees the group', (tester) async {
      var other = 0;
      await tester.pumpWidget(
        _app(
          BouncyExclusiveScope(
            lockDuringLoading: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BouncyButton(
                  onPressedAsync: () => Completer<void>().future,
                  onError: (error, _) => throw ArgumentError('handler bug'),
                  timeout: const Duration(seconds: 1),
                  child: const Text('Google'),
                ),
                BouncyButton(
                  onPressedAsync: () async => other++,
                  child: const Text('Apple'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Google'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isA<ArgumentError>());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(other, 1);
    });

    testWidgets('after confirm throws, the button still works', (tester) async {
      var asks = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            onError: (error, _) => throw ArgumentError('handler bug'),
            confirm: () {
              asks++;
              throw StateError('no dialog');
            },
            child: const Text('Delete'),
          ),
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(tester.takeException(), isA<ArgumentError>());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(tester.takeException(), isA<ArgumentError>());
      expect(asks, 2);
    });
  });

  group('changes while confirm is open', () {
    Future<void> pumpButton(
      WidgetTester tester, {
      required bool enabled,
      Future<void> Function()? action,
      VoidCallback? onPressed,
      required Completer<bool> answer,
    }) {
      return tester.pumpWidget(
        _app(
          BouncyButton(
            enabled: enabled,
            onPressed: onPressed,
            onPressedAsync: action,
            confirm: () => answer.future,
            child: const Text('Delete'),
          ),
        ),
      );
    }

    testWidgets('a button disabled meanwhile does nothing', (tester) async {
      var calls = 0;
      final answer = Completer<bool>();
      Future<void> action() async => calls++;
      await pumpButton(tester, enabled: true, action: action, answer: answer);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await pumpButton(tester, enabled: false, action: action, answer: answer);
      answer.complete(true);
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('a plain button disabled meanwhile does nothing',
        (tester) async {
      var calls = 0;
      final answer = Completer<bool>();
      void onPressed() => calls++;
      await pumpButton(
        tester,
        enabled: true,
        onPressed: onPressed,
        answer: answer,
      );
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await pumpButton(
        tester,
        enabled: false,
        onPressed: onPressed,
        answer: answer,
      );
      answer.complete(true);
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('a removed action does nothing', (tester) async {
      var calls = 0;
      final answer = Completer<bool>();
      await pumpButton(
        tester,
        enabled: true,
        action: () async => calls++,
        answer: answer,
      );
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await pumpButton(tester, enabled: true, answer: answer);
      answer.complete(true);
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('a replaced action runs the new one', (tester) async {
      final ran = <String>[];
      final answer = Completer<bool>();
      await pumpButton(
        tester,
        enabled: true,
        action: () async => ran.add('old'),
        answer: answer,
      );
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await pumpButton(
        tester,
        enabled: true,
        action: () async => ran.add('new'),
        answer: answer,
      );
      answer.complete(true);
      await tester.pumpAndSettle();
      expect(ran, ['new']);
    });
  });

  testWidgets('a states controller can be replaced after disposing the old',
      (tester) async {
    var states = WidgetStatesController();
    late StateSetter setOuter;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return BouncyButton(
              statesController: states,
              onPressed: () {},
              child: const Text('x'),
            );
          },
        ),
      ),
    );
    setOuter(() {
      states.dispose();
      states = WidgetStatesController();
    });
    await tester.pump();
    expect(tester.takeException(), isNull);
    addTearDown(states.dispose);
  });
}
