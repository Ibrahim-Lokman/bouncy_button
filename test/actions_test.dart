import 'dart:async';

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsData;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

final Finder _spinner = find.byType(CircularProgressIndicator);
final Finder _tick = find.byIcon(Icons.check_rounded);

double _faceY(WidgetTester tester) => tester.getTopLeft(find.text('x')).dy;

/// Two quick taps, 100ms apart.
Future<void> _doubleTap(WidgetTester tester, Finder target) async {
  await tester.tap(target, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(target, warnIfMissed: false);
  await tester.pump();
}

void main() {
  group('cooldown', () {
    testWidgets('without one, a double tap runs twice', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () => presses++, child: const Text('x'))),
      );
      await _doubleTap(tester, find.text('x'));
      await tester.pumpAndSettle();
      expect(presses, 2);
    });

    testWidgets('a double tap within the cooldown runs once', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            cooldown: const Duration(milliseconds: 500),
            child: const Text('x'),
          ),
        ),
      );
      await _doubleTap(tester, find.text('x'));
      await tester.pumpAndSettle();
      expect(presses, 1);

      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      expect(presses, 2, reason: 'the cooldown is over');
    });

    testWidgets('the button does not move during the cooldown', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            cooldown: const Duration(seconds: 1),
            child: const Text('x'),
          ),
        ),
      );
      final rest = _faceY(tester);
      await tester.tap(find.text('x'));
      // Let the tap's own press and release finish, within the cooldown.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(_faceY(tester), rest);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_faceY(tester), rest);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('applies to keyboard activation and long press',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      var presses = 0;
      var longPresses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            onLongPress: () => longPresses++,
            focusNode: node,
            cooldown: const Duration(milliseconds: 800),
            child: const Text('x'),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(presses, 1);
      await tester.pumpAndSettle();

      await tester.longPress(find.text('x'));
      await tester.pump();
      await tester.longPress(find.text('x'));
      await tester.pumpAndSettle();
      expect(longPresses, 1);
    });

    testWidgets('works on BouncyPressable', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () => taps++,
            cooldown: const Duration(milliseconds: 500),
            child: const Text('x'),
          ),
        ),
      );
      await _doubleTap(tester, find.text('x'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('an async button cools down after it is ready again',
        (tester) async {
      var runs = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async => runs++,
            cooldown: const Duration(milliseconds: 500),
            feedback: const BouncyButtonFeedback(showSuccess: false),
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pump();
      expect(runs, 1);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('x'));
      await tester.pump();
      expect(runs, 1, reason: 'still cooling down');

      await tester.pumpAndSettle();
      await tester.tap(find.text('x'));
      await tester.pump();
      expect(runs, 2);
      await tester.pumpAndSettle();
    });

    testWidgets('errors cool down too', (tester) async {
      var runs = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async {
              runs++;
              throw StateError('x');
            },
            onError: (_, __) {},
            cooldown: const Duration(milliseconds: 500),
            feedback: const BouncyButtonFeedback(showError: false),
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('x'));
      await tester.pump();
      expect(runs, 1);
      await tester.pumpAndSettle();
    });
  });

  group('minimum loading time', () {
    testWidgets('a fast action still shows loading for the minimum',
        (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async {},
            feedback: const BouncyButtonFeedback(
              minLoadingDuration: Duration(milliseconds: 400),
            ),
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(_spinner, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(_spinner, findsNothing);
      expect(_tick, findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('a slow action is not delayed further', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            feedback: const BouncyButtonFeedback(
              minLoadingDuration: Duration(milliseconds: 100),
            ),
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      completer.complete();
      await tester.pump();
      expect(_tick, findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('loading text', () {
    testWidgets('shows beside the spinner and is announced', (tester) async {
      final handle = tester.ensureSemantics();
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            feedback: const BouncyButtonFeedback(loadingText: 'Saving'),
            child: const Text('Save changes'),
          ),
        ),
      );
      final size = tester.getSize(find.byType(BouncyButton));
      await tester.tap(find.text('Save changes'));
      await tester.pump();
      expect(_spinner, findsOneWidget);
      expect(find.text('Saving'), findsOneWidget);
      expect(tester.getSize(find.byType(BouncyButton)), size);
      final SemanticsData data =
          tester.getSemantics(find.byType(BouncyButton)).getSemanticsData();
      expect(data.value, 'Saving');
      completer.complete();
      await tester.pumpAndSettle();
      handle.dispose();
    });

    testWidgets('long text is cut off rather than overflowing', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            feedback: const BouncyButtonFeedback(
              loadingText: 'Saving your changes to the server, please wait',
            ),
            child: const Text('Go'),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('BouncyButtonController', () {
    testWidgets('press runs the action and completes when it ends',
        (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      final completer = Completer<void>();
      var runs = 0;
      final statuses = <BouncyButtonStatus>[];
      controller.addListener(() => statuses.add(controller.status));
      await tester.pumpWidget(
        _app(
          BouncyButton(
            controller: controller,
            onPressedAsync: () {
              runs++;
              return completer.future;
            },
            child: const Text('x'),
          ),
        ),
      );
      expect(controller.isAttached, isTrue);
      var done = false;
      controller.press().then((_) => done = true);
      final again = controller.press();
      await tester.pump();
      expect(runs, 1, reason: 'a second press waits for the first');
      expect(controller.status, BouncyButtonStatus.loading);

      completer.complete();
      await tester.pump();
      await again;
      expect(done, isTrue);
      await tester.pumpAndSettle();
      expect(statuses, [
        BouncyButtonStatus.loading,
        BouncyButtonStatus.success,
        BouncyButtonStatus.idle,
      ]);
    });

    testWidgets('press on a plain button calls onPressed with the animation',
        (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            controller: controller,
            onPressed: () => presses++,
            child: const Text('x'),
          ),
        ),
      );
      final rest = _faceY(tester);
      await controller.press();
      expect(presses, 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(_faceY(tester), greaterThan(rest));
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);
    });

    testWidgets('press does nothing when disabled', (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            controller: controller,
            enabled: false,
            onPressed: () => presses++,
            child: const Text('x'),
          ),
        ),
      );
      await controller.press();
      expect(presses, 0);
    });

    testWidgets('reset ends a result, and ignores a late action',
        (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            controller: controller,
            onPressedAsync: () => completer.future,
            child: const Text('x'),
          ),
        ),
      );
      controller.press();
      await tester.pump();
      controller.reset();
      await tester.pump();
      expect(controller.status, BouncyButtonStatus.idle);
      expect(_spinner, findsNothing);

      completer.complete();
      await tester.pump();
      expect(_tick, findsNothing, reason: 'the late result is ignored');
      expect(controller.status, BouncyButtonStatus.idle);
    });

    testWidgets('detaches when the button goes away', (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          BouncyButton(
            controller: controller,
            onPressed: () {},
            child: const Text('x'),
          ),
        ),
      );
      expect(controller.isAttached, isTrue);
      await tester.pumpWidget(_app(const SizedBox()));
      expect(controller.isAttached, isFalse);
      await controller.press();
    });

    testWidgets('can move to another button', (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      var a = 0;
      var b = 0;
      Widget build({required bool onA}) => _app(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BouncyButton(
                  controller: onA ? controller : null,
                  onPressed: () => a++,
                  child: const Text('a'),
                ),
                BouncyButton(
                  controller: onA ? null : controller,
                  onPressed: () => b++,
                  child: const Text('b'),
                ),
              ],
            ),
          );
      await tester.pumpWidget(build(onA: true));
      await tester.pumpWidget(build(onA: false));
      await controller.press();
      await tester.pumpAndSettle();
      expect((a, b), (0, 1));
    });

    testWidgets('removing a loading button tells listeners safely',
        (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      final completer = Completer<void>();
      final statuses = <BouncyButtonStatus>[];
      var showButton = true;
      late StateSetter rebuildParent;
      // A listener that rebuilds a widget which stays on screen, as apps
      // commonly do.
      controller.addListener(() {
        statuses.add(controller.status);
        rebuildParent(() {});
      });
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              rebuildParent = setState;
              return showButton
                  ? BouncyButton(
                      controller: controller,
                      onPressedAsync: () => completer.future,
                      child: const Text('x'),
                    )
                  : const SizedBox();
            },
          ),
        ),
      );
      controller.press();
      await tester.pump();
      expect(statuses, [BouncyButtonStatus.loading]);

      rebuildParent(() => showButton = false);
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(statuses.last, BouncyButtonStatus.idle);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('isLoading is reported as loading', (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          BouncyButton(
            controller: controller,
            onPressed: () {},
            isLoading: true,
            child: const Text('x'),
          ),
        ),
      );
      expect(controller.status, BouncyButtonStatus.loading);
    });
  });

  group('group lock', () {
    Widget pair({
      required Future<void> Function() onA,
      required Future<void> Function() onB,
      bool lock = true,
      bool showA = true,
    }) {
      return _app(
        BouncyExclusiveScope(
          lockDuringLoading: lock,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Keys, so removing a keeps b and c's own state.
              if (showA)
                BouncyButton(
                  key: const Key('a'),
                  onPressedAsync: onA,
                  child: const Text('a'),
                ),
              BouncyButton(
                key: const Key('b'),
                onPressedAsync: onB,
                child: const Text('b'),
              ),
              BouncyAsyncBuilder(
                key: const Key('c'),
                onPressed: onB,
                builder: (context, onPressed, status) => TextButton(
                  onPressed: onPressed,
                  child: const Text('c'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('while one loads, the others wait', (tester) async {
      final completer = Completer<void>();
      var others = 0;
      await tester.pumpWidget(
        pair(onA: () => completer.future, onB: () async => others++),
      );
      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.tap(find.text('b'), warnIfMissed: false);
      await tester.tap(find.text('c'), warnIfMissed: false);
      await tester.pump();
      expect(others, 0);

      completer.complete();
      await tester.pumpAndSettle();
      await tester.tap(find.text('b'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('c'));
      await tester.pumpAndSettle();
      expect(others, 2);
    });

    testWidgets('the waiting buttons look disabled', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        pair(onA: () => completer.future, onB: () async {}),
      );
      Color faceOf(String label) => (tester
              .widget<Container>(
                find.descendant(
                  of: find.ancestor(
                    of: find.text(label),
                    matching: find.byType(BouncyButton),
                  ),
                  matching: find.byWidgetPredicate(
                    (w) => w is Container && w.decoration is BoxDecoration,
                  ),
                ),
              )
              .decoration! as BoxDecoration)
          .color!;
      final enabledColor = faceOf('b');
      await tester.tap(find.text('a'));
      await tester.pump();
      expect(faceOf('b'), isNot(enabledColor));
      completer.complete();
      await tester.pumpAndSettle();
      expect(faceOf('b'), enabledColor);
    });

    testWidgets('without the lock, both run', (tester) async {
      final completer = Completer<void>();
      var others = 0;
      await tester.pumpWidget(
        pair(
          onA: () => completer.future,
          onB: () async => others++,
          lock: false,
        ),
      );
      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.tap(find.text('b'));
      await tester.pump();
      expect(others, 1);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('removing the loading button frees the lock', (tester) async {
      final completer = Completer<void>();
      var others = 0;
      await tester.pumpWidget(
        pair(onA: () => completer.future, onB: () async => others++),
      );
      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.pumpWidget(
        pair(
          onA: () => completer.future,
          onB: () async => others++,
          showA: false,
        ),
      );
      // The lock is released after that frame, and b rebuilds on the next.
      await tester.pump();
      await tester.tap(find.text('b'));
      await tester.pumpAndSettle();
      expect(others, 1);
    });

    testWidgets('plain buttons are not locked', (tester) async {
      final completer = Completer<void>();
      var plain = 0;
      await tester.pumpWidget(
        _app(
          BouncyExclusiveScope(
            lockDuringLoading: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BouncyButton(
                  onPressedAsync: () => completer.future,
                  child: const Text('a'),
                ),
                BouncyButton(
                  onPressed: () => plain++,
                  child: const Text('b'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.tap(find.text('b'));
      await tester.pump();
      expect(plain, 1);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('BouncyAsyncBuilder', () {
    testWidgets('guards any button and reports the status', (tester) async {
      final completer = Completer<void>();
      var runs = 0;
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            onPressed: () {
              runs++;
              return completer.future;
            },
            builder: (context, onPressed, status) => ElevatedButton(
              onPressed: onPressed,
              child: Text(status.name),
            ),
          ),
        ),
      );
      expect(find.text('idle'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(runs, 1);
      expect(find.text('loading'), findsOneWidget);

      completer.complete();
      await tester.pump();
      expect(find.text('success'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('two calls in the same frame run once', (tester) async {
      var runs = 0;
      VoidCallback? captured;
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            onPressed: () async => runs++,
            builder: (context, onPressed, status) {
              captured = onPressed;
              return const SizedBox();
            },
          ),
        ),
      );
      captured!();
      captured!();
      await tester.pumpAndSettle();
      expect(runs, 1);
    });

    testWidgets('keeps the callback, and focus, while busy by default',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            onPressed: () => completer.future,
            builder: (context, onPressed, status) => ElevatedButton(
              focusNode: node,
              onPressed: onPressed,
              child: const Text('Pay'),
            ),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(node.hasFocus, isTrue);
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('disableWhileBusy passes null while busy', (tester) async {
      final completer = Completer<void>();
      final callbacks = <bool>[];
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            onPressed: () => completer.future,
            disableWhileBusy: true,
            builder: (context, onPressed, status) {
              callbacks.add(onPressed != null);
              return TextButton(
                onPressed: onPressed,
                child: const Text('x'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pump();
      expect(callbacks.last, isFalse);
      completer.complete();
      await tester.pumpAndSettle();
      expect(callbacks.last, isTrue);
    });

    testWidgets('errors go to onError, or are reported', (tester) async {
      Object? reported;
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            onPressed: () async => throw StateError('a'),
            onError: (error, _) => reported = error,
            builder: (context, onPressed, status) => TextButton(
              onPressed: onPressed,
              child: Text(status.name),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(reported, isA<StateError>());
      expect(find.text('error'), findsOneWidget);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            key: const Key('second'),
            onPressed: () async => throw StateError('b'),
            builder: (context, onPressed, status) => TextButton(
              onPressed: onPressed,
              child: const Text('x'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(tester.takeException(), isA<StateError>());
      await tester.pumpAndSettle();
    });

    testWidgets('announces the status on the button', (tester) async {
      final handle = tester.ensureSemantics();
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            onPressed: () => completer.future,
            builder: (context, onPressed, status) => TextButton(
              onPressed: onPressed,
              child: const Text('Pay'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      final data = tester.getSemantics(find.text('Pay')).getSemanticsData();
      expect(data.label, 'Pay');
      expect(data.value, 'Loading');
      completer.complete();
      await tester.pumpAndSettle();
      handle.dispose();
    });

    testWidgets('a null action gives a null callback', (tester) async {
      VoidCallback? captured = () {};
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            onPressed: null,
            builder: (context, onPressed, status) {
              captured = onPressed;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, isNull);
    });

    testWidgets('supports a controller and a cooldown', (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      var runs = 0;
      await tester.pumpWidget(
        _app(
          BouncyAsyncBuilder(
            controller: controller,
            cooldown: const Duration(milliseconds: 500),
            feedback: const BouncyButtonFeedback(showSuccess: false),
            onPressed: () async => runs++,
            builder: (context, onPressed, status) => const SizedBox(),
          ),
        ),
      );
      await controller.press();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await controller.press();
      expect(runs, 1);
      await tester.pumpAndSettle();
      await controller.press();
      expect(runs, 2);
      await tester.pumpAndSettle();
    });
  });
}
