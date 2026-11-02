import 'dart:io';

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

double _faceY(WidgetTester tester) => tester.getTopLeft(find.text('x')).dy;

void main() {
  group('callbacks', () {
    testWidgets('a tap reports down, up, then pressed', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => events.add('pressed'),
            onTapDown: (_) => events.add('down'),
            onTapUp: (_) => events.add('up'),
            onTapCancel: () => events.add('cancel'),
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      expect(events, ['down', 'up', 'pressed']);
    });

    testWidgets('dragging away reports down, then cancel', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => events.add('pressed'),
            onTapDown: (_) => events.add('down'),
            onTapUp: (_) => events.add('up'),
            onTapCancel: () => events.add('cancel'),
            child: const Text('x'),
          ),
        ),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 150));
      await gesture.moveBy(const Offset(0, 300));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(events, ['down', 'cancel']);
    });

    testWidgets('splash reports each event once, with no cancel after a tap',
        (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => events.add('pressed'),
            onTapDown: (_) => events.add('down'),
            onTapUp: (_) => events.add('up'),
            onTapCancel: () => events.add('cancel'),
            interaction: const BouncyButtonInteraction(enableSplash: true),
            child: const Text('x'),
          ),
        ),
      );
      // A hold past the tap deadline makes both inner and outer recognizers
      // report the press.
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 150));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(events, ['down', 'up', 'pressed']);
    });

    testWidgets('disabling while held reports a cancel after the frame',
        (tester) async {
      final events = <String>[];
      Widget button({required bool enabled}) => _app(
            BouncyButton(
              onPressed: () {},
              enabled: enabled,
              onTapDown: (_) => events.add('down'),
              onTapCancel: () => events.add('cancel'),
              child: const Text('x'),
            ),
          );
      await tester.pumpWidget(button(enabled: true));
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 150));

      await tester.pumpWidget(button(enabled: false));
      expect(tester.takeException(), isNull);
      expect(events, ['down', 'cancel']);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(events, ['down', 'cancel']);
    });

    testWidgets('a long press does not report a tap up', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => events.add('pressed'),
            onLongPress: () => events.add('long'),
            onTapDown: (_) => events.add('down'),
            onTapUp: (_) => events.add('up'),
            onTapCancel: () => events.add('cancel'),
            child: const Text('x'),
          ),
        ),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(events, ['down', 'cancel', 'long']);
    });
  });

  group('long press only', () {
    testWidgets('stays enabled and looks enabled', (tester) async {
      var longPresses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: null,
            onLongPress: () => longPresses++,
            style: const BouncyButtonStyle(
              backgroundColor: Colors.teal,
              disabledColor: Colors.grey,
            ),
            child: const Text('x'),
          ),
        ),
      );
      final face = tester.widget<Container>(
        find.descendant(
          of: find.byType(BouncyButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container && widget.decoration is BoxDecoration,
          ),
        ),
      );
      expect((face.decoration! as BoxDecoration).color, Colors.teal);

      await tester.longPress(find.text('x'));
      await tester.pumpAndSettle();
      expect(longPresses, 1);
    });

    testWidgets('a plain tap does nothing', (tester) async {
      var longPresses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: null,
            onLongPress: () => longPresses++,
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      expect(longPresses, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Enter does nothing and does not throw', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: null,
            onLongPress: () {},
            focusNode: node,
            child: const Text('x'),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('with enabled false it is disabled', (tester) async {
      var longPresses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: null,
            enabled: false,
            onLongPress: () => longPresses++,
            child: const Text('x'),
          ),
        ),
      );
      await tester.longPress(find.text('x'));
      await tester.pumpAndSettle();
      expect(longPresses, 0);
    });
  });

  group('press timing', () {
    testWidgets('pressing again during a quick tap holds the button down',
        (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            animation: const BouncyButtonAnimation(
              duration: Duration(milliseconds: 200),
            ),
            child: const Text('x'),
          ),
        ),
      );
      final rest = _faceY(tester);
      final center = tester.getCenter(find.text('x'));

      // Release early, so the release is waiting for the press to finish.
      final first = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 20));
      await first.up();
      await tester.pump(const Duration(milliseconds: 20));

      final second = await tester.startGesture(center);
      // The first frame only starts the animation's clock.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(_faceY(tester) - rest, 8, reason: 'should stay fully down');

      await second.up();
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);
    });

    testWidgets('pressing again during the release goes back down',
        (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            animation: const BouncyButtonAnimation(
              duration: Duration(milliseconds: 100),
            ),
            child: const Text('x'),
          ),
        ),
      );
      final rest = _faceY(tester);
      final center = tester.getCenter(find.text('x'));

      final first = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));
      await first.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(_faceY(tester) - rest, lessThan(8));

      final second = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));
      expect(_faceY(tester) - rest, 8);

      await second.up();
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);
    });

    testWidgets('keyboard activation always returns to rest', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            focusNode: node,
            child: const Text('x'),
          ),
        ),
      );
      final rest = _faceY(tester);
      node.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(presses, 1);
      expect(_faceY(tester), rest);
    });
  });

  testWidgets('hitTestBehavior reaches the gesture detector', (tester) async {
    await tester.pumpWidget(
      _app(
        BouncyButton(
          onPressed: () {},
          hitTestBehavior: HitTestBehavior.translucent,
          child: const Text('x'),
        ),
      ),
    );
    final detector = tester.widget<GestureDetector>(
      find
          .descendant(
            of: find.byType(BouncyButton),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    expect(detector.behavior, HitTestBehavior.translucent);
  });

  test('the layers below the button do not import Material', () {
    const files = [
      'lib/src/press_core.dart',
      'lib/src/press_transform.dart',
      'lib/src/animations.dart',
      'lib/src/styles.dart',
      'lib/src/enums.dart',
    ];
    for (final path in files) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('material.dart')), reason: path);
      expect(source, isNot(contains('cupertino.dart')), reason: path);
    }
  });
}
