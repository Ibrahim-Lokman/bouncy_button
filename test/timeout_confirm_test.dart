import 'dart:async';

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

final Finder _spinner = find.byType(CircularProgressIndicator);
final Finder _errorIcon = find.byIcon(Icons.error_outline_rounded);
final Finder _tick = find.byIcon(Icons.check_rounded);

/// The timeout runs on an animation, which finishes on the first frame after
/// the limit has passed.
const Duration _frame = Duration(milliseconds: 16);

void main() {
  group('timeout', () {
    testWidgets('a hanging action shows an error and unlocks', (tester) async {
      final errors = <Object>[];
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () {
              calls++;
              return Completer<void>().future;
            },
            onError: (error, _) => errors.add(error),
            timeout: const Duration(seconds: 5),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(_spinner, findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      expect(_spinner, findsOneWidget);
      expect(errors, isEmpty);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(_frame);
      expect(_errorIcon, findsOneWidget);
      expect(errors.single, isA<TimeoutException>());
      expect(
        (errors.single as TimeoutException).duration,
        const Duration(seconds: 5),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(calls, 2);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('a late result is ignored, and a late error reported',
        (tester) async {
      final completer = Completer<void>();
      final errors = <Object>[];
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            onError: (error, _) => errors.add(error),
            timeout: const Duration(seconds: 1),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(errors, hasLength(1));

      completer.completeError(StateError('late'));
      await tester.pump();
      expect(errors, hasLength(2));
      expect(errors.last, isA<StateError>());
      // The button stays idle: the late error doesn't show again.
      expect(_errorIcon, findsNothing);
      expect(_tick, findsNothing);
    });

    testWidgets('a fast action is not affected', (tester) async {
      final errors = <Object>[];
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () =>
                Future<void>.delayed(const Duration(milliseconds: 100)),
            onError: (error, _) => errors.add(error),
            timeout: const Duration(seconds: 1),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(_tick, findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(errors, isEmpty);
    });

    testWidgets('releases the group lock', (tester) async {
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
                  onError: (_, __) {},
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
      await tester.tap(find.text('Apple'));
      await tester.pump();
      expect(other, 0);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(other, 1);
    });

    testWidgets('the controller future completes at the timeout',
        (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          BouncyButton(
            controller: controller,
            onPressedAsync: () => Completer<void>().future,
            onError: (_, __) {},
            timeout: const Duration(seconds: 1),
            child: const Text('Pay'),
          ),
        ),
      );
      var done = false;
      unawaited(controller.press().then((_) => done = true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(_frame);
      expect(done, isTrue);
      expect(controller.status, BouncyButtonStatus.error);
      await tester.pumpAndSettle();
    });

    testWidgets('works on BouncyAsyncBuilder', (tester) async {
      final errors = <Object>[];
      BouncyButtonStatus? last;
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            onPressed: () => Completer<void>().future,
            onError: (error, _) => errors.add(error),
            timeout: const Duration(seconds: 1),
            builder: (context, onPressed, status) {
              last = status;
              return TextButton(
                onPressed: onPressed,
                child: const Text('Send'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Send'));
      await tester.pump();
      expect(last, BouncyButtonStatus.loading);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(_frame);
      expect(last, BouncyButtonStatus.error);
      expect(errors.single, isA<TimeoutException>());
      await tester.pumpAndSettle();
    });

    testWidgets('without onError, the timeout is reported', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => Completer<void>().future,
            timeout: const Duration(seconds: 1),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(_frame);
      expect(tester.takeException(), isA<TimeoutException>());
      await tester.pumpAndSettle();
    });
  });

  group('confirm', () {
    testWidgets('runs the action only after a yes', (tester) async {
      var answer = Completer<bool>();
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async => calls++,
            confirm: () => answer.future,
            child: const Text('Delete'),
          ),
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.pump();
      // Waiting for an answer shows no loading.
      expect(_spinner, findsNothing);
      expect(calls, 0);

      answer.complete(false);
      await tester.pumpAndSettle();
      expect(calls, 0);

      answer = Completer<bool>();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      answer.complete(true);
      await tester.pumpAndSettle();
      expect(calls, 1);
    });

    testWidgets('a double tap asks once', (tester) async {
      final answer = Completer<bool>();
      var asks = 0;
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => calls++,
            confirm: () {
              asks++;
              return answer.future;
            },
            child: const Text('Delete'),
          ),
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(asks, 1);

      answer.complete(true);
      await tester.pumpAndSettle();
      expect(calls, 1);
    });

    testWidgets('works with a real dialog', (tester) async {
      var deleted = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: BouncyButton(
                  onPressedAsync: () async => deleted++,
                  confirm: () async =>
                      await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      ) ??
                      false,
                  child: const Text('Delete'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(deleted, 0);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(deleted, 1);
    });

    testWidgets('a throw is reported and nothing runs', (tester) async {
      final errors = <Object>[];
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async => calls++,
            onError: (error, _) => errors.add(error),
            confirm: () => throw StateError('no dialog'),
            child: const Text('Delete'),
          ),
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(errors.single, isA<StateError>());
      // The button works again afterwards.
      expect(_errorIcon, findsNothing);
    });

    testWidgets('the controller confirms too', (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      var asks = 0;
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            controller: controller,
            onPressedAsync: () async => calls++,
            confirm: () async {
              asks++;
              return true;
            },
            child: const Text('Delete'),
          ),
        ),
      );
      final run = controller.press();
      await tester.pumpAndSettle();
      await run;
      expect(asks, 1);
      expect(calls, 1);
    });

    testWidgets('a reset while asking cancels the action', (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      final answer = Completer<bool>();
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            controller: controller,
            onPressedAsync: () async => calls++,
            confirm: () => answer.future,
            child: const Text('Delete'),
          ),
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.pump();
      controller.reset();
      answer.complete(true);
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('removing the button while asking is safe', (tester) async {
      final answer = Completer<bool>();
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => calls++,
            confirm: () => answer.future,
            child: const Text('Delete'),
          ),
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pumpWidget(_app(const SizedBox()));
      answer.complete(true);
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('works on BouncyAsyncBuilder', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            onPressed: () async => calls++,
            confirm: () async => false,
            builder: (context, onPressed, status) => TextButton(
              onPressed: onPressed,
              child: const Text('Send'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(calls, 0);
    });
  });
}
