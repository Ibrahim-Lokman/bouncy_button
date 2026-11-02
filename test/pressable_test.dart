import 'dart:io';

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

double _scale(WidgetTester tester, Finder pressable) {
  final transform = tester.widget<Transform>(
    find.descendant(of: pressable, matching: find.byType(Transform)).first,
  );
  // The x scale. getMaxScaleOnAxis would include z, which stays at 1.
  return transform.transform.storage[0];
}

const Key _outerKey = Key('outer');
const Key _middleKey = Key('middle');
const Key _innerKey = Key('inner');

final Finder _outer = find.byKey(_outerKey);
final Finder _middle = find.byKey(_middleKey);
final Finder _inner = find.byKey(_innerKey);

/// An outer pressable, 300 square, with a 100 square inner one at its center.
Widget _nested({
  VoidCallback? onOuter,
  VoidCallback? onInner,
  VoidCallback? onOuterLong,
  VoidCallback? onOuterCancel,
  VoidCallback? onInnerCancel,
  GestureTapDownCallback? onOuterDown,
}) {
  return _app(
    BouncyPressable(
      key: _outerKey,
      onTap: onOuter ?? () {},
      onLongPress: onOuterLong,
      onTapCancel: onOuterCancel,
      onTapDown: onOuterDown,
      child: Container(
        width: 300,
        height: 300,
        alignment: Alignment.center,
        color: const Color(0xFF1976D2),
        child: BouncyPressable(
          key: _innerKey,
          onTap: onInner ?? () {},
          onTapCancel: onInnerCancel,
          child: Container(
            width: 100,
            height: 100,
            color: const Color(0xFFD32F2F),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('press effect', () {
    testWidgets('scales down while held and returns on release',
        (tester) async {
      var taps = 0;
      final pressable = find.byType(BouncyPressable);
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () => taps++,
            scaleFactor: 0.8,
            child: const Text('x'),
          ),
        ),
      );
      expect(_scale(tester, pressable), 1);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_scale(tester, pressable), closeTo(0.8, 0.001));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_scale(tester, pressable), 1);
      expect(taps, 1);
    });

    testWidgets('a quick tap still shows the full press', (tester) async {
      final pressable = find.byType(BouncyPressable);
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () {},
            scaleFactor: 0.8,
            child: const Text('x'),
          ),
        ),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 20));
      await gesture.up();

      var lowest = 1.0;
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 10));
        final scale = _scale(tester, pressable);
        if (scale < lowest) {
          lowest = scale;
        }
      }
      expect(lowest, closeTo(0.8, 0.001));
      expect(_scale(tester, pressable), 1);
    });

    testWidgets('changing settings at runtime takes effect', (tester) async {
      final pressable = find.byType(BouncyPressable);
      Widget build(double factor) => _app(
            BouncyPressable(
              onTap: () {},
              scaleFactor: factor,
              child: const Text('x'),
            ),
          );
      await tester.pumpWidget(build(0.9));
      await tester.pumpWidget(build(0.5));
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_scale(tester, pressable), closeTo(0.5, 0.001));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('reduced motion leaves the size alone', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _app(
            BouncyPressable(
              onTap: () => taps++,
              child: const Text('x'),
            ),
          ),
        ),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump();
      await tester.pump();
      expect(_scale(tester, find.byType(BouncyPressable)), 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('disabled when given no callbacks', (tester) async {
      await tester.pumpWidget(
        _app(const BouncyPressable(onTap: null, child: Text('x'))),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_scale(tester, find.byType(BouncyPressable)), 1);
      await gesture.up();
    });

    testWidgets('long press works with no tap callback', (tester) async {
      var longPresses = 0;
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: null,
            onLongPress: () => longPresses++,
            child: const Text('x'),
          ),
        ),
      );
      await tester.longPress(find.text('x'));
      await tester.pumpAndSettle();
      expect(longPresses, 1);
    });

    test('rejects an invalid scale factor', () {
      expect(
        () => BouncyPressable(
          onTap: () {},
          scaleFactor: 1.5,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('scrolling', () {
    testWidgets('dragging a list does not tap, and the item recovers',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          ListView(
            children: [
              for (var i = 0; i < 30; i++)
                BouncyPressable(
                  onTap: () => taps++,
                  child: SizedBox(height: 80, child: Text('item $i')),
                ),
            ],
          ),
        ),
      );
      final list = tester.getTopLeft(find.byType(ListView));
      final gesture = await tester.startGesture(list + const Offset(50, 200));
      // Long enough for the press to show before the drag begins.
      await tester.pump(const Duration(milliseconds: 150));
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(0, -40));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(taps, 0);
      for (final element in find.byType(BouncyPressable).evaluate()) {
        expect(
          _scale(tester, find.byWidget(element.widget)),
          1,
          reason: 'no item should stay pressed',
        );
      }
    });

    testWidgets('a tap in a list still fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          ListView(
            children: [
              BouncyPressable(
                onTap: () => taps++,
                child: const SizedBox(height: 80, child: Text('item')),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('item'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });

  group('nesting', () {
    testWidgets('a quick tap on the inner one only fires the inner one',
        (tester) async {
      var outer = 0;
      var inner = 0;
      await tester.pumpWidget(
        _nested(onOuter: () => outer++, onInner: () => inner++),
      );
      await tester.tap(_inner);
      await tester.pumpAndSettle();
      expect(inner, 1);
      expect(outer, 0);
    });

    testWidgets('holding the inner one leaves the outer one still',
        (tester) async {
      final outerEvents = <String>[];
      await tester.pumpWidget(
        _nested(
          onOuterDown: (_) => outerEvents.add('down'),
          onOuterCancel: () => outerEvents.add('cancel'),
        ),
      );
      final gesture = await tester.startGesture(tester.getCenter(_inner));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(_scale(tester, _inner), closeTo(0.95, 0.001));
      expect(_scale(tester, _outer), 1);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_scale(tester, _inner), 1);
      expect(_scale(tester, _outer), 1);
      expect(outerEvents, isEmpty, reason: 'the press was never the outer one');
    });

    testWidgets('pressing outside the inner one presses the outer one',
        (tester) async {
      var outer = 0;
      var inner = 0;
      await tester.pumpWidget(
        _nested(onOuter: () => outer++, onInner: () => inner++),
      );
      final corner = tester.getTopLeft(_outer) + const Offset(10, 10);
      final gesture = await tester.startGesture(corner);
      await tester.pumpAndSettle();
      expect(_scale(tester, _outer), closeTo(0.95, 0.001));
      expect(_scale(tester, _inner), 1);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(outer, 1);
      expect(inner, 0);
    });

    testWidgets('the outer one can press again after the inner one',
        (tester) async {
      await tester.pumpWidget(_nested());
      await tester.tap(_inner);
      await tester.pumpAndSettle();

      final corner = tester.getTopLeft(_outer) + const Offset(10, 10);
      final gesture = await tester.startGesture(corner);
      await tester.pumpAndSettle();
      expect(_scale(tester, _outer), closeTo(0.95, 0.001));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a long press on the outer one takes over from the inner one',
        (tester) async {
      var long = 0;
      var inner = 0;
      var innerCancels = 0;
      await tester.pumpWidget(
        _nested(
          onOuterLong: () => long++,
          onInner: () => inner++,
          onInnerCancel: () => innerCancels++,
        ),
      );
      final gesture = await tester.startGesture(tester.getCenter(_inner));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_scale(tester, _outer), 1, reason: 'before the long press');

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(long, 1);
      expect(innerCancels, 1);
      expect(_scale(tester, _inner), 1);
      expect(_scale(tester, _outer), closeTo(0.95, 0.001));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(inner, 0);
      expect(_scale(tester, _outer), 1);
    });

    testWidgets('three levels: holding the innermost stills both others',
        (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            key: _outerKey,
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: BouncyPressable(
                key: _middleKey,
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(60),
                  child: BouncyPressable(
                    key: _innerKey,
                    onTap: () {},
                    child: const SizedBox.square(dimension: 60),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(tester.getCenter(_inner));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(_scale(tester, _inner), closeTo(0.95, 0.001));
      expect(_scale(tester, _middle), 1);
      expect(_scale(tester, _outer), 1);

      await gesture.up();
      await tester.pumpAndSettle();
      final corner = tester.getTopLeft(_outer) + const Offset(10, 10);
      final second = await tester.startGesture(corner);
      await tester.pumpAndSettle();
      expect(_scale(tester, _outer), closeTo(0.95, 0.001));
      await second.up();
      await tester.pumpAndSettle();
    });

    testWidgets('removing the inner one mid-press frees the outer one',
        (tester) async {
      Widget build({required bool showInner}) => _app(
            BouncyPressable(
              key: _outerKey,
              onTap: () {},
              child: SizedBox.square(
                dimension: 300,
                child: Center(
                  child: showInner
                      ? BouncyPressable(
                          key: _innerKey,
                          onTap: () {},
                          child: const SizedBox.square(dimension: 100),
                        )
                      : const SizedBox.square(dimension: 100),
                ),
              ),
            ),
          );
      await tester.pumpWidget(build(showInner: true));
      final gesture = await tester.startGesture(tester.getCenter(_inner));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpWidget(build(showInner: false));
      expect(tester.takeException(), isNull);
      await gesture.up();
      await tester.pumpAndSettle();

      final next = await tester.startGesture(tester.getCenter(_outer));
      await tester.pumpAndSettle();
      expect(_scale(tester, _outer), closeTo(0.95, 0.001));
      await next.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a button inside a pressable also yields', (tester) async {
      var button = 0;
      var card = 0;
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            key: _outerKey,
            onTap: () => card++,
            child: SizedBox.square(
              dimension: 300,
              child: Center(
                child: BouncyButton(
                  onPressed: () => button++,
                  child: const Text('x'),
                ),
              ),
            ),
          ),
        ),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(_scale(tester, _outer), 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(button, 1);
      expect(card, 0);
    });
  });

  group('exclusive scope', () {
    Widget pair({
      required VoidCallback onA,
      required VoidCallback onB,
      VoidCallback? onLongB,
      bool scoped = true,
      bool showA = true,
      bool enableA = true,
    }) {
      final row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showA)
            BouncyPressable(
              onTap: onA,
              enabled: enableA,
              child: const SizedBox(width: 100, height: 100, child: Text('a')),
            ),
          const SizedBox(width: 50),
          BouncyPressable(
            onTap: onB,
            onLongPress: onLongB,
            child: const SizedBox(width: 100, height: 100, child: Text('b')),
          ),
        ],
      );
      return _app(scoped ? BouncyExclusiveScope(child: row) : row);
    }

    testWidgets('a second finger is ignored while the first is down',
        (tester) async {
      var a = 0;
      var b = 0;
      await tester.pumpWidget(pair(onA: () => a++, onB: () => b++));
      final first = await tester.startGesture(tester.getCenter(find.text('a')));
      await tester.pump(const Duration(milliseconds: 150));
      final second =
          await tester.startGesture(tester.getCenter(find.text('b')));
      await tester.pump(const Duration(milliseconds: 150));

      await second.up();
      await first.up();
      await tester.pumpAndSettle();
      expect(a, 1);
      expect(b, 0);
    });

    testWidgets('without a scope, both fingers fire', (tester) async {
      var a = 0;
      var b = 0;
      await tester.pumpWidget(
        pair(onA: () => a++, onB: () => b++, scoped: false),
      );
      final first = await tester.startGesture(tester.getCenter(find.text('a')));
      await tester.pump(const Duration(milliseconds: 150));
      final second =
          await tester.startGesture(tester.getCenter(find.text('b')));
      await tester.pump(const Duration(milliseconds: 150));

      await second.up();
      await first.up();
      await tester.pumpAndSettle();
      expect(a, 1);
      expect(b, 1);
    });

    testWidgets('separate taps both fire', (tester) async {
      var a = 0;
      var b = 0;
      await tester.pumpWidget(pair(onA: () => a++, onB: () => b++));
      await tester.tap(find.text('a'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('b'));
      await tester.pumpAndSettle();
      expect(a, 1);
      expect(b, 1);
    });

    testWidgets('an ignored finger can tap normally next time', (tester) async {
      var a = 0;
      var b = 0;
      await tester.pumpWidget(pair(onA: () => a++, onB: () => b++));
      final first = await tester.startGesture(tester.getCenter(find.text('a')));
      await tester.pump(const Duration(milliseconds: 150));
      final second =
          await tester.startGesture(tester.getCenter(find.text('b')));
      await tester.pump(const Duration(milliseconds: 150));
      await second.up();
      await first.up();
      await tester.pumpAndSettle();

      await tester.tap(find.text('b'));
      await tester.pumpAndSettle();
      expect(b, 1);
    });

    testWidgets('an ignored finger does not long press either', (tester) async {
      var long = 0;
      await tester.pumpWidget(
        pair(onA: () {}, onB: () {}, onLongB: () => long++),
      );
      final first = await tester.startGesture(tester.getCenter(find.text('a')));
      await tester.pump(const Duration(milliseconds: 150));
      final second =
          await tester.startGesture(tester.getCenter(find.text('b')));
      await tester.pump(const Duration(milliseconds: 700));
      await second.up();
      await first.up();
      await tester.pumpAndSettle();
      expect(long, 0);
    });

    testWidgets('removing the holder frees the press', (tester) async {
      var b = 0;
      await tester.pumpWidget(pair(onA: () {}, onB: () => b++));
      final first = await tester.startGesture(tester.getCenter(find.text('a')));
      await tester.pump(const Duration(milliseconds: 150));
      final bCenter = tester.getCenter(find.text('b'));

      await tester.pumpWidget(pair(onA: () {}, onB: () => b++, showA: false));
      await first.up();
      await tester.pumpAndSettle();

      final b2 = tester.getCenter(find.text('b'));
      expect(bCenter, isNotNull);
      await tester.tapAt(b2);
      await tester.pumpAndSettle();
      expect(b, 1);
    });

    testWidgets('disabling the holder frees the press', (tester) async {
      var b = 0;
      await tester.pumpWidget(pair(onA: () {}, onB: () => b++));
      final first = await tester.startGesture(tester.getCenter(find.text('a')));
      await tester.pump(const Duration(milliseconds: 150));

      await tester.pumpWidget(pair(onA: () {}, onB: () => b++, enableA: false));
      await tester.tap(find.text('b'));
      await tester.pumpAndSettle();
      expect(b, 1);
      await first.up();
      await tester.pumpAndSettle();
    });

    testWidgets('keyboard activation ignores the scope', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      var b = 0;
      await tester.pumpWidget(
        _app(
          BouncyExclusiveScope(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BouncyPressable(
                  onTap: () {},
                  child: const SizedBox(
                    width: 100,
                    height: 100,
                    child: Text('a'),
                  ),
                ),
                BouncyPressable(
                  onTap: () => b++,
                  focusNode: node,
                  child: const SizedBox(width: 100, height: 100),
                ),
              ],
            ),
          ),
        ),
      );
      final first = await tester.startGesture(tester.getCenter(find.text('a')));
      await tester.pump(const Duration(milliseconds: 150));
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(b, 1);
      await first.up();
      await tester.pumpAndSettle();
    });

    testWidgets('works with BouncyButton too', (tester) async {
      var a = 0;
      var b = 0;
      await tester.pumpWidget(
        _app(
          BouncyExclusiveScope(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BouncyButton(onPressed: () => a++, child: const Text('a')),
                const SizedBox(width: 50),
                BouncyButton(onPressed: () => b++, child: const Text('b')),
              ],
            ),
          ),
        ),
      );
      final first = await tester.startGesture(tester.getCenter(find.text('a')));
      await tester.pump(const Duration(milliseconds: 150));
      final second =
          await tester.startGesture(tester.getCenter(find.text('b')));
      await tester.pump(const Duration(milliseconds: 150));
      await second.up();
      await first.up();
      await tester.pumpAndSettle();
      expect(a, 1);
      expect(b, 0);
    });
  });

  group('keyboard', () {
    testWidgets('Enter activates when the wrapper has focus', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      var taps = 0;
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () => taps++,
            focusNode: node,
            child: const Text('x'),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('Enter in a focused child does not activate the wrapper',
        (tester) async {
      final child = FocusNode();
      addTearDown(child.dispose);
      var taps = 0;
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () => taps++,
            child: Focus(focusNode: child, child: const Text('x')),
          ),
        ),
      );
      child.requestFocus();
      await tester.pump();
      expect(child.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 0);
    });

    testWidgets('a text field inside still receives focus', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () {},
            child: const SizedBox(width: 300, child: TextField()),
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);
    });

    testWidgets('a focus ring shows during keyboard navigation',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () {},
            focusNode: node,
            focusColor: Colors.amber,
            child: const Text('x'),
          ),
        ),
      );
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      node.requestFocus();
      await tester.pump();
      final ring = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(BouncyPressable),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.position == DecorationPosition.foreground,
          ),
        ),
      );
      final border = (ring.decoration as BoxDecoration).border! as Border;
      expect(border.top.color, Colors.amber);
    });
  });

  group('semantics', () {
    testWidgets('is a button by default, keeping the child label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () {},
            semanticLabel: 'Open',
            child: const Text('Card title'),
          ),
        ),
      );
      final data =
          tester.getSemantics(find.byType(BouncyPressable)).getSemanticsData();
      expect(data.label, contains('Open'));
      expect(data.label, contains('Card title'));
      handle.dispose();
    });

    testWidgets('with semanticsButton off, inner controls stay reachable',
        (tester) async {
      final handle = tester.ensureSemantics();
      var inner = 0;
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () {},
            semanticsButton: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Card title'),
                BouncyPressable(
                  onTap: () => inner++,
                  semanticLabel: 'Save',
                  child: const SizedBox.square(dimension: 48),
                ),
              ],
            ),
          ),
        ),
      );
      final save = tester.getSemantics(find.bySemanticsLabel('Save'));
      expect(save.label, 'Save');
      tester.semantics.tap(find.semantics.byLabel('Save'));
      await tester.pumpAndSettle();
      expect(inner, 1);
      expect(find.bySemanticsLabel('Card title'), findsOneWidget);
      handle.dispose();
    });
  });

  test('the pressable layer does not import Material', () {
    const files = [
      'lib/pressable.dart',
      'lib/src/pressable.dart',
      'lib/src/exclusive_scope.dart',
      'lib/src/press_core.dart',
      'lib/src/async_builder.dart',
      'lib/src/async_action.dart',
      'lib/src/controller.dart',
      'lib/src/feedback.dart',
      'lib/src/enums.dart',
      'lib/src/spring.dart',
    ];
    for (final path in files) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('material.dart')), reason: path);
    }
  });
}
