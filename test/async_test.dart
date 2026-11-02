import 'dart:async';

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsData;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {ThemeData? theme, bool reduceMotion = false}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: MaterialApp(
      theme: theme,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

final Finder _spinner = find.byType(CircularProgressIndicator);
final Finder _tick = find.byIcon(Icons.check_rounded);
final Finder _errorIcon = find.byIcon(Icons.error_outline_rounded);

/// Whether the button label is showing, rather than a status.
bool _labelVisible(WidgetTester tester) {
  final visibility = tester.widget<Visibility>(
    find.ancestor(of: find.text('Pay'), matching: find.byType(Visibility)),
  );
  return visibility.visible;
}

void main() {
  group('onPressedAsync', () {
    testWidgets('shows loading, then success, then the label again',
        (tester) async {
      final completer = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () {
              calls++;
              return completer.future;
            },
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(calls, 1);
      expect(_spinner, findsOneWidget);
      expect(_labelVisible(tester), isFalse);

      completer.complete();
      await tester.pump();
      expect(_spinner, findsNothing);
      expect(_tick, findsOneWidget);

      await tester.pumpAndSettle();
      expect(_tick, findsNothing);
      expect(_labelVisible(tester), isTrue);
    });

    testWidgets('ignores presses until it is idle again', (tester) async {
      final completer = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () {
              calls++;
              return completer.future;
            },
            onLongPress: () => calls += 100,
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      await tester.tap(find.text('Pay'), warnIfMissed: false);
      await tester.pump();
      await tester.longPress(find.text('Pay'), warnIfMissed: false);
      await tester.pump();
      expect(calls, 1);

      completer.complete();
      await tester.pump();
      await tester.tap(find.text('Pay'), warnIfMissed: false);
      await tester.pump();
      expect(calls, 1, reason: 'success is still showing');

      await tester.pumpAndSettle();
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(calls, 2);
    });

    testWidgets('does not move while loading', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            child: const Text('Pay'),
          ),
        ),
      );
      final rest = tester.getTopLeft(find.text('Pay')).dy;
      Future<void> frames() async {
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      }

      await tester.tap(find.text('Pay'));
      // Let the tap's own press and release finish.
      await frames();
      expect(tester.getTopLeft(find.text('Pay')).dy, rest);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(BouncyButton)),
      );
      await frames();
      expect(tester.getTopLeft(find.text('Pay')).dy, rest);
      await gesture.up();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a touch during the quick tap release does not stick',
        (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            child: const Text('Pay'),
          ),
        ),
      );
      final rest = tester.getTopLeft(find.text('Pay')).dy;
      await tester.tap(find.text('Pay'));
      await tester.pump(const Duration(milliseconds: 16));
      // Touch again while the tap's press is still finishing.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(BouncyButton)),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.getTopLeft(find.text('Pay')).dy, rest);
      await gesture.up();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('keeps its size while the content changes', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            child: const Text('Place your order'),
          ),
        ),
      );
      final idle = tester.getSize(find.byType(BouncyButton));
      await tester.tap(find.text('Place your order'));
      await tester.pump();
      expect(tester.getSize(find.byType(BouncyButton)), idle);
      completer.complete();
      await tester.pump();
      expect(tester.getSize(find.byType(BouncyButton)), idle);
      await tester.pumpAndSettle();
    });

    testWidgets('keeps keyboard focus, and Enter is ignored while loading',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final completer = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            focusNode: node,
            onPressedAsync: () {
              calls++;
              return completer.future;
            },
            child: const Text('Pay'),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(calls, 1);
      expect(node.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(calls, 1);

      completer.complete();
      await tester.pumpAndSettle();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('being removed while waiting is safe', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      await tester.pumpWidget(_app(const SizedBox()));

      completer.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('showSuccess false returns straight to the label',
        (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            feedback: const BouncyButtonFeedback(showSuccess: false),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      completer.complete();
      await tester.pump();
      expect(_tick, findsNothing);
      expect(_labelVisible(tester), isTrue);
    });

    testWidgets('custom builders replace the defaults', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            feedback: BouncyButtonFeedback(
              loadingBuilder: (_) => const Text('Wait'),
              successBuilder: (_) => const Text('Paid'),
            ),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(find.text('Wait'), findsOneWidget);
      completer.complete();
      await tester.pump();
      expect(find.text('Paid'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('feedback can come from the theme', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            child: const Text('Pay'),
          ),
          theme: ThemeData(
            extensions: [
              BouncyButtonTheme(
                defaultFeedback: BouncyButtonFeedback(
                  loadingBuilder: (_) => const Text('Themed wait'),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(find.text('Themed wait'), findsOneWidget);
      completer.complete();
      await tester.pumpAndSettle();
    });

    test('cannot be combined with onPressed', () {
      expect(
        () => BouncyButton(
          onPressed: () {},
          onPressedAsync: () async {},
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('errors', () {
    testWidgets('a failure shows the error, then the label again',
        (tester) async {
      final completer = Completer<void>();
      Object? reported;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            onError: (error, _) => reported = error,
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      completer.completeError(StateError('declined'));
      await tester.pump();
      expect(reported, isA<StateError>());
      expect(_errorIcon, findsOneWidget);

      await tester.pumpAndSettle();
      expect(_errorIcon, findsNothing);
      expect(_labelVisible(tester), isTrue);
    });

    testWidgets('a synchronous throw is caught too', (tester) async {
      Object? reported;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => throw StateError('invalid'),
            onError: (error, _) => reported = error,
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(reported, isA<StateError>());
      expect(_errorIcon, findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('without onError, the error is reported, not swallowed',
        (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async => throw StateError('lost'),
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(tester.takeException(), isA<StateError>());
      await tester.pumpAndSettle();
    });

    testWidgets('the button shakes on error', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async => throw StateError('x'),
            onError: (_, __) {},
            child: const Text('Pay'),
          ),
        ),
      );
      // The hidden label stays laid out, and moves with the face.
      double labelX() => tester.getTopLeft(find.text('Pay')).dx;
      final restX = labelX();
      await tester.tap(find.text('Pay'));
      await tester.pump();
      var moved = 0.0;
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final dx = (labelX() - restX).abs();
        if (dx > moved) {
          moved = dx;
        }
      }
      expect(moved, greaterThan(2));
      await tester.pumpAndSettle();
      expect(labelX(), restX);
    });

    testWidgets('reduced motion skips the shake', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () async => throw StateError('x'),
            onError: (_, __) {},
            child: const Text('Pay'),
          ),
          reduceMotion: true,
        ),
      );
      double labelX() => tester.getTopLeft(find.text('Pay')).dx;
      final restX = labelX();
      await tester.tap(find.text('Pay'));
      await tester.pump();
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(labelX(), restX);
      }
      expect(_errorIcon, findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('isLoading', () {
    testWidgets('shows loading and ignores presses', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            isLoading: true,
            child: const Text('Pay'),
          ),
        ),
      );
      expect(_spinner, findsOneWidget);
      await tester.tap(find.byType(BouncyButton));
      await tester.pump();
      expect(presses, 0);

      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            isLoading: false,
            child: const Text('Pay'),
          ),
        ),
      );
      expect(_spinner, findsNothing);
      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();
      expect(presses, 1);
    });
  });

  group('semantics', () {
    testWidgets('announces loading and the result, keeping the label',
        (tester) async {
      final handle = tester.ensureSemantics();
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressedAsync: () => completer.future,
            child: const Text('Pay'),
          ),
        ),
      );
      SemanticsData data() =>
          tester.getSemantics(find.byType(BouncyButton)).getSemanticsData();
      expect(data().value, isEmpty);

      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(data().label, 'Pay');
      expect(data().value, 'Loading');

      completer.complete();
      await tester.pump();
      expect(data().value, 'Done');

      await tester.pumpAndSettle();
      expect(data().value, isEmpty);
      handle.dispose();
    });

    testWidgets('labels can be translated', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            isLoading: true,
            feedback: const BouncyButtonFeedback(loadingLabel: 'Chargement'),
            child: const Text('Payer'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(BouncyButton)).getSemanticsData().value,
        'Chargement',
      );
      handle.dispose();
    });
  });

  test('feedback has value equality', () {
    expect(
      const BouncyButtonFeedback(loadingLabel: 'a'),
      const BouncyButtonFeedback(loadingLabel: 'a'),
    );
    expect(
      const BouncyButtonFeedback().copyWith(showError: false),
      const BouncyButtonFeedback(showError: false),
    );
  });
}
